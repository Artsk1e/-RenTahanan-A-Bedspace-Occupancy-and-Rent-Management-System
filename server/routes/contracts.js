const express = require('express');
const router = express.Router();
const contractController = require('../controllers/contractController');
const auth = require('../middleware/auth');

router.get('/', auth(['OWNER', 'CARETAKER']), contractController.getAllContracts);
router.post('/', auth(['OWNER', 'CARETAKER']), contractController.createContract);
router.put('/:id/terminate', auth(['OWNER', 'CARETAKER']), contractController.terminateContract);

module.exports = router;