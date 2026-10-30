const pool = require('../config/db');

// Get all tenants
exports.getAllTenants = async (req, res) => {
  try {
    const tenants = await pool.query('SELECT * FROM tenants');
    res.json(tenants.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: 'Server error' });
  }
};

// Get tenant by ID
exports.getTenantById = async (req, res) => {
  const { id } = req.params;
  try {
    const tenant = await pool.query('SELECT * FROM tenants WHERE tenant_id = $1', [id]);
    if (tenant.rows.length === 0) {
      return res.status(404).json({ error: 'Tenant not found' });
    }
    res.json(tenant.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: 'Server error' });
  }
};

// Create a new tenant profile
exports.createTenant = async (req, res) => {
  const { user_id, first_name, last_name, contact_number, emergency_contact, status } = req.body;

  if (!first_name || !last_name || !contact_number || !emergency_contact) {
    return res.status(400).json({ error: 'First name, last name, contact number, and emergency contact are required' });
  }

  try {
    const newTenant = await pool.query(
      'INSERT INTO tenants (user_id, first_name, last_name, contact_number, emergency_contact, status) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
      [user_id || null, first_name, last_name, contact_number, emergency_contact, status || 'ACTIVE']
    );
    res.status(201).json(newTenant.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: 'Server error' });
  }
};

// Update tenant profile
exports.updateTenant = async (req, res) => {
  const { id } = req.params;
  const { user_id, first_name, last_name, contact_number, emergency_contact, status } = req.body;

  try {
    const existingTenant = await pool.query('SELECT * FROM tenants WHERE tenant_id = $1', [id]);
    if (existingTenant.rows.length === 0) {
      return res.status(404).json({ error: 'Tenant not found' });
    }

    const updatedTenant = await pool.query(
      'UPDATE tenants SET user_id = $1, first_name = $2, last_name = $3, contact_number = $4, emergency_contact = $5, status = $6, updated_at = CURRENT_TIMESTAMP WHERE tenant_id = $7 RETURNING *',
      [user_id, first_name, last_name, contact_number, emergency_contact, status, id]
    );
    res.json(updatedTenant.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: 'Server error' });
  }
};

// Delete tenant profile
exports.deleteTenant = async (req, res) => {
  const { id } = req.params;
  try {
    const existingTenant = await pool.query('SELECT * FROM tenants WHERE tenant_id = $1', [id]);
    if (existingTenant.rows.length === 0) {
      return res.status(404).json({ error: 'Tenant not found' });
    }

    await pool.query('DELETE FROM tenants WHERE tenant_id = $1', [id]);
    res.status(200).json({ message: 'Tenant deleted successfully' });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: 'Server error' });
  }
};