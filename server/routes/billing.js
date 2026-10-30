const express = require('express');
const router = express.Router();
const billingController = require('../controllers/billingController');
const auth = require('../middleware/auth');

router.get('/', auth(['OWNER', 'CARETAKER']), billingController.getAllBilling);
router.post('/', auth(['OWNER', 'CARETAKER']), billingController.createBilling);

module.exports = router;