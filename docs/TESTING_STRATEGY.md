# 🧪 MINI MARKET — TESTING STRATEGY & QUALITY ASSURANCE

**Document Version**: 1.0.0  
**Quality Target**: Zero Warnings, Zero Untracked Errors, 100% CI Workflow Success  
**Tooling**: `flutter test`, `pytest-django`, `coverage`, `flake8`  

---

## 1. Quality Assurance Pyramid

```text
               / \
              /   \
             / E2E \       15% - Full Business Lifecycle Workflows
            /-------\
           /  Widget \     35% - POS Cart, Keypads, Form Validation, UI States
          /-----------\
         /    Unit     \   50% - Monetary Math, Stock Deltas, Tax, Data Parsers
        /---------------\
```

---

## 2. Core Test Suites

### 2.1 Flutter Testing Suite
- **Decimal Math Accuracy**: Unit tests asserting that rounding $19.99 \times 3$ with $12.5\%$ tax and $5\%$ discount yields exact cent precision without floating point drift.
- **Offline Sync Queue**: Tests asserting that 10 sales created while offline are properly queued, serialized, and transmitted without duplication upon network reconnection.
- **POS Cart State**: Tests verifying item additions, quantity modifications, price overrides (with permissions), discounts, and hold-cart switching.
- **Theme & Responsiveness**: Widget tests verifying layouts render without RenderFlex overflows across $360\,\text{dp}$ (small phone) up to $1200\,\text{dp}$ (tablet POS).

### 2.2 Django Backend Testing Suite
- **Atomic Concurrency**: Stress tests validating that 10 simultaneous checkout requests for a product with 5 units in stock allow exactly 5 units to sell and return `INSUFFICIENT_STOCK` for the rest without corrupting the stock balance.
- **Financial Balances**: Tests verifying that a sale total matches the exact sum of line items + taxes - discounts.
- **Audit Logging**: Tests verifying that modifying a product cost price or voiding a transaction triggers an immutable `AuditLog` record containing `previous_state` and `new_state`.

---

## 3. End-to-End Retail Scenario Walkthrough

Every major release must pass the **14-Step Retail Store Simulation**:

1. **Store Setup**: Initialize business parameters, tax rules, and currency symbol (`$`).
2. **Category Creation**: Create `Fresh Produce`, `Dairy`, `Beverages`, `Bakery`.
3. **Product Cataloging**: Add 5 retail products with barcodes, cost prices, and selling prices.
4. **Supplier Onboarding**: Register supplier `Beverage World Ltd` with 30-day payment terms.
5. **Purchase Order**: Create PO `#PO-1001` for 100 units of Sparkling Water at $\$0.80$ cost.
6. **Goods Receipt**: Receive PO `#PO-1001` through Goods Received Note; verify inventory updates from $0 \rightarrow 100$.
7. **Shift Opening**: Cashier logs in via 4-digit PIN, opens drawer with $\$100.00$ float.
8. **POS Sale (Cash)**: Cashier scans 2 Sparkling Waters ($\$3.00$), accepts $\$5.00$ cash, validates $\$2.00$ change, confirms receipt.
9. **Stock Verification**: Assert inventory decrements from $100 \rightarrow 98$ with an immutable `SALE` movement record.
10. **POS Sale (Split Payment)**: Sell 1 item for $\$20.00$ using $\$10.00$ Cash and $\$10.00$ Card.
11. **Expense Recording**: Record store utility expense of $\$45.00$ from petty cash.
12. **Shift Closing**: Count cash in drawer, compare expected vs actual, generate shift reconciliation statement.
13. **Profit & Loss Audit**: Check `/api/reports/profit-loss/` to ensure Revenue, COGS, and Expenses calculate net profit accurately.
14. **Audit Trail Inspection**: Verify all actions are documented with timestamps and user identifiers.
