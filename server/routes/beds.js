const express = require('express');
const router = express.Router();
const bedController = require('../controllers/bedController');
const auth = require('../middleware/auth');

// Publicly available within the organization
router.get('/', auth(['OWNER', 'CARETAKER', 'TENANT']), bedController.getAllBeds);
router.get('/:id', auth(['OWNER', 'CARETAKER', 'TENANT']), bedController.getBedById);

// Staff-only access
router.post('/', auth(['OWNER', 'CARETAKER']), bedController.createBed);
router.put('/:id', auth(['OWNER', 'CARETAKER']), bedController.updateBed);
router.delete('/:id', auth(['OWNER']), bedController.deleteBed);

module.exports = router;