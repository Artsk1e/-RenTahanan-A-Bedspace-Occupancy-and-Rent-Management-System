const pool = require('../config/db');

// Get all payments
exports.getAllPayments = async (req, res) => {
  try {
    const payments = await pool.query(`
      SELECT payments.*, tenants.first_name, tenants.last_name, users.username as logged_by 
      FROM payments 
      JOIN tenants ON payments.tenant_id = tenants.tenant_id
      LEFT JOIN users ON payments.logged_by_user_id = users.user_id
    `);
    res.json(payments.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: 'Server error' });
  }
};

// Log a new payment (Record cash collection and OR number)
exports.createPayment = async (req, res) => {
  const { billing_statement_id, tenant_id, amount_paid, or_number, remarks } = req.body;
  const logged_by_user_id = req.user.user_id;

  if (!tenant_id || !amount_paid || !or_number) {
    return res.status(400).json({ error: 'Tenant, amount, and OR number are required' });
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // 1. Check if OR number is unique
    const orCheck = await client.query('SELECT * FROM payments WHERE or_number = $1', [or_number]);
    if (orCheck.rows.length > 0) {
      throw new Error('Official Receipt (OR) number already exists');
    }

    // 2. Create the payment record
    const newPayment = await client.query(
      `INSERT INTO payments 
      (billing_statement_id, tenant_id, logged_by_user_id, amount_paid, or_number, remarks) 
      VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
      [billing_statement_id || null, tenant_id, logged_by_user_id, amount_paid, or_number, remarks]
    );

    // 3. Update billing statement status to PAID if linked and amount matches (Business rule)
    if (billing_statement_id) {
        const billing = await client.query('SELECT amount_due FROM billing_statements WHERE billing_statement_id = $1', [billing_statement_id]);
        if (billing.rows.length > 0) {
            // Partial payments are NOT allowed (per business rules), so we mark as PAID if amount matches
            if (parseFloat(amount_paid) >= parseFloat(billing.rows[0].amount_due)) {
                await client.query("UPDATE billing_statements SET status = 'PAID' WHERE billing_statement_id = $1", [billing_statement_id]);
            }
        }
    }

    await client.query('COMMIT');
    res.status(201).json(newPayment.rows[0]);
  } catch (err) {
    await client.query('ROLLBACK');
    console.error(err.message);
    res.status(400).json({ error: err.message || 'Server error logging payment' });
  } finally {
    client.release();
  }
};