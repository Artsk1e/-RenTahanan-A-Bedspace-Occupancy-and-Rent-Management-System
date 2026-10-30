const express = require('express');
const router = express.Router();
const tenantController = require('../controllers/tenantController');
const auth = require('../middleware/auth');

// Staff-only access to view all tenants
router.get('/', auth(['OWNER', 'CARETAKER']), tenantController.getAllTenants);
router.get('/:id', auth(['OWNER', 'CARETAKER', 'TENANT']), tenantController.getTenantById);

// Staff-only access to modify tenant profiles
router.post('/', auth(['OWNER', 'CARETAKER']), tenantController.createTenant);
router.put('/:id', auth(['OWNER', 'CARETAKER']), tenantController.updateTenant);
router.delete('/:id', auth(['OWNER']), tenantController.deleteTenant);

module.exports = router;