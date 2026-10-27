// server/server.js
const express = require('express');
const cors = require('cors');
const pool = require('./config/db');
require('dotenv').config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

//Test Endpoint: Fetch test beds from database
app.get('/api/test-beds', async (req, res) => {
    try {
        const result = await pool.query('SELECT beds.bed\_id, beds.bed\_code, beds.status, rooms.room\_number, rooms.type FROM beds JOIN rooms ON beds.room\_id = rooms.room\_id'
        );
        res.json({
            message: 'Database connection successful',
            data:result.rows,
    });
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ error: 'Server error querying database' });
    }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});