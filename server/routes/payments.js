const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/paymentController');
const auth = require('../middleware/auth');

router.get('/', auth(['OWNER', 'CARETAKER']), paymentController.getAllPayments);
router.post('/', auth(['OWNER', 'CARETAKER']), paymentController.createPayment);

module.exports = router;