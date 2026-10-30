const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const pool = require('../config/db');

// Get all users (Owner only)
router.get('/', auth(['OWNER']), async (req, res) => {
  try {
    const users = await pool.query('SELECT user_id, username, role, created_at FROM users');
    res.json(users.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;