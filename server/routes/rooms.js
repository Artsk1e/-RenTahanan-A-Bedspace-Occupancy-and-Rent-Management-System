const express = require('express');
const router = express.Router();
const roomController = require('../controllers/roomController');
const auth = require('../middleware/auth');

// Publicly available within the organization
router.get('/', auth(['OWNER', 'CARETAKER', 'TENANT']), roomController.getAllRooms);
router.get('/:id', auth(['OWNER', 'CARETAKER', 'TENANT']), roomController.getRoomById);

// Staff-only access
router.post('/', auth(['OWNER', 'CARETAKER']), roomController.createRoom);
router.put('/:id', auth(['OWNER', 'CARETAKER']), roomController.updateRoom);
router.delete('/:id', auth(['OWNER']), roomController.deleteRoom);

module.exports = router;