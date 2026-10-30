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