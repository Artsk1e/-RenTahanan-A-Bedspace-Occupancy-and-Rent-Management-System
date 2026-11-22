---
name: rental-payment-rules
description: Rent calculations, due dates, payment records, outstanding balances, deposits, penalties for RenTahanan
---

# Rental Payment Rules

## Rent Calculation

### Monthly Rate
- **Flat rate per bed** — Defined on `contracts.monthly_rate`
- **All-inclusive** — Utilities (water, electricity, wifi) bundled
- **No metering** — No per-usage charges
- **Currency**: Philippine Peso (PHP), stored as `NUMERIC(10,2)`

### Advance Rent
- **Collected at contract signing** — `contracts.advance_rent_paid`
- **Typical**: 1-2 months upfront
- **Applied to**: First N months of billing (business logic, not auto-deducted)
- **Tracking**: Separate column, not part of `billing_statements`

### Security Deposit
- **Collected at contract signing** — `contracts.deposit_paid`
- **Refundable** — On move-out, minus damages/unpaid rent
- **Tracking**: Separate column, not part of `billing_statements`
- **Business Rule**: Not applied to monthly rent automatically

## Billing Cycle

### Generation
- **Frequency**: Monthly
- **Trigger**: Manual by Caretaker/Owner via `POST /api/billing`
- **Timing**: Typically generated a few days before due date
- **Amount**: Equals `contract.monthly_rate` (can be overridden per statement)

### Due Dates
- **Standard**: 1st-5th of each month (configurable per contract)
- **Field**: `billing_statements.due_date` (DATE)
- **Grace Period**: None formally defined (OVERDUE immediately after due_date)

### Status Transitions
| From | To | Trigger |
|------|-----|---------|
| `UNPAID` | `PAID` | Full exact payment received (`amount_paid == amount_due`) |
| `UNPAID` | `OVERDUE` | `due_date` passed without full payment |
| `OVERDUE` | `PAID` | Full exact payment received |

## Payment Rules

### Cash Collection
- **Method**: Cash only (current implementation)
- **Collector**: Caretaker or Owner (logged via `logged_by_user_id`)
- **Mandatory**: Official Receipt (OR) number — `payments.or_number` (UNIQUE)

### Official Receipt (OR) Number
- **Format**: Per business requirements (e.g., `OR-2026-000123`)
- **Uniqueness**: Enforced at DB (`UNIQUE` constraint) + API check
- **Sequential**: Recommended but not enforced by DB

### Payment Amount
- **Exact amount required**: `amount_paid == billing_statements.amount_due` to mark `PAID`
- **Overpayment**: **REJECTED** — Returns 400
- **Partial**: **REJECTED** — Returns 400, billing remains `UNPAID`

### Walk-in Payments
- **Allowed**: `billing_statement_id` nullable on `payments`
- **Use Case**: Tenant pays without pre-generated billing statement
- **Linkage**: Linked to `tenant_id` only; manual reconciliation needed

## Balance Tracking

### Outstanding Balance (Per Tenant)
```
Outstanding = Σ(billing.amount_due) - Σ(payments.amount_paid for linked billings)
            + Σ(walk-in payments not linked)
```
- **Computed at query time** — No stored balance column
- **Used for**: Tenant dashboard, debt flagging, move-out settlement

### Move-out Settlement
1. Calculate outstanding balance
2. Apply security deposit (`contract.deposit_paid`)
3. Refund excess or collect shortfall
4. Update `tenant.status` → `MOVED_OUT` or `FLAGGED_DEBT`

## Penalties & Late Fees

### Current Status
- **No automated late fees** implemented
- **OVERDUE status** is the only penalty mechanism
- **Business Decision Needed**: Late fee structure (fixed amount? percentage? grace period?)

### Open Questions (⚠️ UNVERIFIED)
- [ ] Is there a grace period after due_date?
- [ ] Late fee: fixed amount or percentage of monthly rate?
- [ ] Maximum late fee cap?
- [ ] Interest on overdue balances?
- [ ] Partial payment handling if policy changes?

## Payment Recording Workflow

```typescript
// POST /api/payments
// 1. Validate OR number uniqueness (DB check)
// 2. If billing_statement_id provided:
//    - Verify billing exists and belongs to tenant
//    - Check amount_paid >= billing.amount_due
//    - If yes: billing.status = 'PAID'
//    - If no:  return 400 (partial not allowed)
// 3. If no billing_statement_id (walk-in):
//    - Record payment linked to tenant only
// 4. Insert payment record
// 5. Return payment with updated billing status
```

## Financial Reports Needed

| Report | Description |
|--------|-------------|
| Monthly Collection | Total payments per month, by OR |
| Outstanding Balances | Per tenant, aged by due date |
| Deposit Ledger | Deposits held, refunded, forfeited |
| Advance Rent Tracker | Advance applied vs remaining |
| Occupancy Revenue | Monthly rate × occupied beds |