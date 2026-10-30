const pool = require('../config/db');

// Get all contracts
exports.getAllContracts = async (req, res) => {
  try {
    const contracts = await pool.query(`
      SELECT contracts.*, tenants.first_name, tenants.last_name, beds.bed_code 
      FROM contracts 
      JOIN tenants ON contracts.tenant_id = tenants.tenant_id 
      JOIN beds ON contracts.bed_id = beds.bed_id
    `);
    res.json(contracts.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: 'Server error' });
  }
};

// Create a new contract (Assigns a tenant to a bed and marks it OCCUPIED)
exports.createContract = async (req, res) => {
  const { tenant_id, bed_id, start_date, end_date, monthly_rate, advance_rent_paid, deposit_paid } = req.body;
  const created_by_user_id = req.user.user_id;

  if (!tenant_id || !bed_id || !start_date || !end_date || !monthly_rate) {
    return res.status(400).json({ error: 'Tenant, bed, start date, end date, and monthly rate are required' });
  }

  const client = await pool.connect();

  try {
    await client.query('BEGIN');

    // 1. Check if the bed is already occupied
    const bedCheck = await client.query('SELECT status FROM beds WHERE bed_id = $1 FOR UPDATE', [bed_id]);
    if (bedCheck.rows.length === 0) {
      throw new Error('Bed not found');
    }
    if (bedCheck.rows[0].status === 'OCCUPIED') {
      throw new Error('Selected bed is already occupied');
    }

    // 2. Ensure tenant only has one active contract/bed (Business rule)
    const tenantContractCheck = await client.query(
      "SELECT * FROM contracts WHERE tenant_id = $1 AND status = 'ACTIVE'",
      [tenant_id]
    );
    if (tenantContractCheck.rows.length > 0) {
      throw new Error('Tenant already has an active contract/bedspace');
    }

    // 3. Create the contract
    const newContract = await client.query(
      `INSERT INTO contracts 
      (tenant_id, bed_id, created_by_user_id, start_date, end_date, monthly_rate, advance_rent_paid, deposit_paid, status) 
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 'ACTIVE') RETURNING *`,
      [
        tenant_id, 
        bed_id, 
        created_by_user_id, 
        start_date, 
        end_date, 
        monthly_rate, 
        advance_rent_paid || 0.00, 
        deposit_paid || 0.00
      ]
    );

    // 4. Update the bed status to OCCUPIED
    await client.query("UPDATE beds SET status = 'OCCUPIED' WHERE bed_id = $1", [bed_id]);

    await client.query('COMMIT');
    res.status(201).json({
      message: 'Contract created and bed assigned successfully',
      contract: newContract.rows[0]
    });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error(err.message);
    res.status(400).json({ error: err.message || 'Server error during contract creation' });
  } finally {
    client.release();
  }
};

// Terminate or complete a contract (Freed up the bed)
exports.terminateContract = async (req, res) => {
  const { id } = req.params;

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // Get contract details
    const contractResult = await client.query('SELECT * FROM contracts WHERE contract_id = $1', [id]);
    if (contractResult.rows.length === 0) {
      throw new Error('Contract not found');
    }

    const contract = contractResult.rows[0];
    if (contract.status !== 'ACTIVE') {
      throw new Error('Contract is already terminated or completed');
    }

    // Update contract status
    await client.query("UPDATE contracts SET status = 'TERMINATED', updated_at = CURRENT_TIMESTAMP WHERE contract_id = $1", [id]);

    // Free up the bed
    await client.query("UPDATE beds SET status = 'VACANT', updated_at = CURRENT_TIMESTAMP WHERE bed_id = $1", [contract.bed_id]);

    await client.query('COMMIT');
    res.json({ message: 'Contract terminated and bed is now vacant' });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error(err.message);
    res.status(400).json({ error: err.message || 'Server error during contract termination' });
  } finally {
    client.release();
  }
};