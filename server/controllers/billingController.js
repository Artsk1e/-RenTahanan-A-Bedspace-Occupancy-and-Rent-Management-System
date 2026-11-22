const pool = require('../config/db');

// Get all billing statements
exports.getAllBilling = async (req, res) => {
  try {
    const billing = await pool.query(`
      SELECT billing_statements.*, tenants.first_name, tenants.last_name 
      FROM billing_statements 
      JOIN tenants ON billing_statements.tenant_id = tenants.tenant_id
    `);
    res.json(billing.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: 'Server error' });
  }
};

// Generate monthly billing statement for a contract
exports.createBilling = async (req, res) => {
  const { contract_id, due_date, amount_due } = req.body;

  if (!contract_id || !due_date || !amount_due) {
    return res.status(400).json({ error: 'Contract ID, due date, and amount due are required' });
  }

  try {
    // Find contract and tenant
    const contractResult = await pool.query('SELECT tenant_id FROM contracts WHERE contract_id = $1 AND status = \'ACTIVE\'', [contract_id]);
    if (contractResult.rows.length === 0) {
      return res.status(404).json({ error: 'Active contract not found' });
    }

    const tenant_id = contractResult.rows[0].tenant_id;

    const newBilling = await pool.query(
      'INSERT INTO billing_statements (contract_id, tenant_id, due_date, amount_due, status) VALUES ($1, $2, $3, $4, \'UNPAID\') RETURNING *',
      [contract_id, tenant_id, due_date, amount_due]
    );

    res.status(201).json(newBilling.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: 'Server error' });
  }
};

// Check and update overdue billing statements (run weekly per business rules)
// Updates UNPAID bills past due_date to OVERDUE, increments warning count, sets eviction eligibility
exports.checkOverdue = async (req, res) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // Find all UNPAID billing statements where due_date has passed
    const overdueBills = await client.query(`
      SELECT billing_statement_id, due_date 
      FROM billing_statements 
      WHERE status = 'UNPAID' AND due_date < CURRENT_DATE
    `);

    const updated = [];
    for (const bill of overdueBills.rows) {
      // Increment warning count, set status to OVERDUE, set eviction eligible date (due_date + 3 months)
      const result = await client.query(`
        UPDATE billing_statements 
        SET status = 'OVERDUE',
            overdue_warning_count = overdue_warning_count + 1,
            eviction_eligible_date = due_date + INTERVAL '3 months',
            updated_at = CURRENT_TIMESTAMP
        WHERE billing_statement_id = $1
        RETURNING billing_statement_id, overdue_warning_count, eviction_eligible_date
      `, [bill.billing_statement_id]);
      updated.push(result.rows[0]);
    }

    // Also update bed status to OVERDUE for beds with overdue billing
    if (updated.length > 0) {
      const billIds = updated.map(u => u.billing_statement_id).join(',');
      await client.query(`
        UPDATE beds 
        SET status = 'OVERDUE', updated_at = CURRENT_TIMESTAMP
        WHERE bed_id IN (
          SELECT b.bed_id 
          FROM contracts c
          JOIN beds b ON c.bed_id = b.bed_id
          JOIN billing_statements bs ON bs.contract_id = c.contract_id
          WHERE bs.billing_statement_id IN (${billIds}) AND c.status = 'ACTIVE'
        )
      `);
    }

    await client.query('COMMIT');
    res.json({ 
      message: `Overdue check complete. ${updated.length} billing statement(s) updated.`,
      updated 
    });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error(err.message);
    res.status(500).json({ error: 'Server error during overdue check' });
  } finally {
    client.release();
  }
};