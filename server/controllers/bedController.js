const pool = require('../config/db');

// Get all beds
exports.getAllBeds = async (req, res) => {
  try {
    const beds = await pool.query('SELECT beds.*, rooms.room_number FROM beds JOIN rooms ON beds.room_id = rooms.room_id');
    res.json(beds.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: 'Server error' });
  }
};

// Get bed by ID
exports.getBedById = async (req, res) => {
  const { id } = req.params;
  try {
    const bed = await pool.query('SELECT beds.*, rooms.room_number FROM beds JOIN rooms ON beds.room_id = rooms.room_id WHERE bed_id = $1', [id]);
    if (bed.rows.length === 0) {
      return res.status(404).json({ error: 'Bed not found' });
    }
    res.json(bed.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: 'Server error' });
  }
};

// Create a new bed
exports.createBed = async (req, res) => {
  const { room_id, bed_code, status } = req.body;

  if (!room_id || !bed_code) {
    return res.status(400).json({ error: 'Room ID and bed code are required' });
  }

  try {
    // Check if bed code already exists
    const existingBed = await pool.query('SELECT * FROM beds WHERE bed_code = $1', [bed_code]);
    if (existingBed.rows.length > 0) {
      return res.status(400).json({ error: 'Bed code already exists' });
    }

    const newBed = await pool.query(
      'INSERT INTO beds (room_id, bed_code, status) VALUES ($1, $2, $3) RETURNING *',
      [room_id, bed_code, status || 'VACANT']
    );
    res.status(201).json(newBed.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: 'Server error' });
  }
};

// Update a bed
exports.updateBed = async (req, res) => {
  const { id } = req.params;
  const { room_id, bed_code, status } = req.body;

  try {
    const existingBed = await pool.query('SELECT * FROM beds WHERE bed_id = $1', [id]);
    if (existingBed.rows.length === 0) {
      return res.status(404).json({ error: 'Bed not found' });
    }

    const updatedBed = await pool.query(
      'UPDATE beds SET room_id = $1, bed_code = $2, status = $3, updated_at = CURRENT_TIMESTAMP WHERE bed_id = $4 RETURNING *',
      [room_id, bed_code, status, id]
    );
    res.json(updatedBed.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: 'Server error' });
  }
};

// Delete a bed
exports.deleteBed = async (req, res) => {
  const { id } = req.params;
  try {
    const existingBed = await pool.query('SELECT * FROM beds WHERE bed_id = $1', [id]);
    if (existingBed.rows.length === 0) {
      return res.status(404).json({ error: 'Bed not found' });
    }

    await pool.query('DELETE FROM beds WHERE bed_id = $1', [id]);
    res.status(200).json({ message: 'Bed deleted successfully' });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: 'Server error' });
  }
};