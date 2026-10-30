const pool = require('../config/db');

// Get all rooms
exports.getAllRooms = async (req, res) => {
  try {
    const rooms = await pool.query('SELECT * FROM rooms');
    res.json(rooms.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: 'Server error' });
  }
};

// Get room by ID
exports.getRoomById = async (req, res) => {
  const { id } = req.params;
  try {
    const room = await pool.query('SELECT * FROM rooms WHERE room_id = $1', [id]);
    if (room.rows.length === 0) {
      return res.status(404).json({ error: 'Room not found' });
    }
    res.json(room.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: 'Server error' });
  }
};

// Create a new room
exports.createRoom = async (req, res) => {
  const { room_number, type, capacity, floor_level } = req.body;

  if (!room_number || !type || !capacity || !floor_level) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  try {
    // Check if room number already exists
    const existingRoom = await pool.query('SELECT * FROM rooms WHERE room_number = $1', [room_number]);
    if (existingRoom.rows.length > 0) {
      return res.status(400).json({ error: 'Room number already exists' });
    }

    const newRoom = await pool.query(
      'INSERT INTO rooms (room_number, type, capacity, floor_level) VALUES ($1, $2, $3, $4) RETURNING *',
      [room_number, type, capacity, floor_level]
    );
    res.status(201).json(newRoom.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: 'Server error' });
  }
};

// Update a room
exports.updateRoom = async (req, res) => {
  const { id } = req.params;
  const { room_number, type, capacity, floor_level } = req.body;

  try {
    const existingRoom = await pool.query('SELECT * FROM rooms WHERE room_id = $1', [id]);
    if (existingRoom.rows.length === 0) {
      return res.status(404).json({ error: 'Room not found' });
    }

    const updatedRoom = await pool.query(
      'UPDATE rooms SET room_number = $1, type = $2, capacity = $3, floor_level = $4, updated_at = CURRENT_TIMESTAMP WHERE room_id = $5 RETURNING *',
      [room_number, type, capacity, floor_level, id]
    );
    res.json(updatedRoom.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: 'Server error' });
  }
};

// Delete a room
exports.deleteRoom = async (req, res) => {
  const { id } = req.params;
  try {
    const existingRoom = await pool.query('SELECT * FROM rooms WHERE room_id = $1', [id]);
    if (existingRoom.rows.length === 0) {
      return res.status(404).json({ error: 'Room not found' });
    }

    await pool.query('DELETE FROM rooms WHERE room_id = $1', [id]);
    res.status(200).json({ message: 'Room deleted successfully' });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: 'Server error' });
  }
};