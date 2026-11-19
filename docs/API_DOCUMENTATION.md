# 📡 MINI MARKET — API SPECIFICATION & INTEGRATION GUIDE

**Document Version**: 1.0.0  
**Base URL**: `https://api.minimarket.local/api/v1/` (Local / Production Gateway)  
**Authentication**: Bearer JWT (`Authorization: Bearer <access_token>`)  
**Standard Serialization**: JSON (UTF-8) with ISO-8601 Timestamps  

---

## 1. Global Standards & Conventions

### 1.1 Standard Response Envelope
```json
{
  "success": true,
  "data": {},
  "meta": {
    "page": 1,
    "page_size": 20,
    "total_count": 142,
    "total_pages": 8
  },
  "errors": null
}
```

### 1.2 Error Envelope
```json
{
  "success": false,
  "data": null,
  "errors": [
    {
      "code": "INSUFFICIENT_STOCK",
      "field": "product_id",
      "message": "Product 'Fresh Organic Milk' has only 3 units in stock, but 5 were requested."
    }
  ]
}
```

---

## 2. API Endpoint Matrix by Domain

### 2.1 Authentication & User Management (`/api/accounts/`)
| Method | Endpoint | Description | Permissions |
| :--- | :--- | :--- | :--- |
| `POST` | `/token/` | Obtain JWT token pair (username + password) | Public |
| `POST` | `/token/refresh/` | Rotate access token via refresh token | Public |
| `POST` | `/pin-login/` | Fast 4-digit PIN cashier authentication | Store Cashiers |
| `GET` | `/me/` | Current user profile, store details & permissions | Authenticated |
| `GET/POST`| `/users/` | List and create employee users | Admin / Manager |
| `GET/PUT` | `/users/{id}/` | Retrieve, update or deactivate employee | Admin / Manager |
| `GET` | `/roles/` | List system roles & permission sets | Admin |

### 2.2 Point of Sale & Cashier Sessions (`/api/pos/`)
| Method | Endpoint | Description | Permissions |
| :--- | :--- | :--- | :--- |
| `GET` | `/shifts/active/` | Check active shift for current cashier/terminal | Cashier |
| `POST` | `/shifts/open/` | Open cashier shift with opening cash drawer float | Cashier |
| `POST` | `/shifts/{id}/close/` | Close shift, record counted cash & print reconciliation | Cashier |
| `POST` | `/checkout/` | Process sale atomically (cash/card/split/customer credit) | Cashier |
| `GET` | `/sales/` | Filter sales history by date, cashier, payment method | Cashier / Manager |
| `GET` | `/sales/{id}/receipt/`| Generate thermal receipt data / printable PDF | Authenticated |
| `POST` | `/sales/{id}/void/` | Void / Cancel completed transaction | Manager / Admin |
| `POST` | `/sales/{id}/refund/`| Process partial or full item return & inventory restock | Manager / Admin |

### 2.3 Product Catalog & Barcode Scanner (`/api/products/`)
| Method | Endpoint | Description | Permissions |
| :--- | :--- | :--- | :--- |
| `GET` | `/items/` | Paginated product search (query, barcode, category) | Authenticated |
| `POST` | `/items/` | Create new retail product with SKU, barcode, cost/sell | Manager / Admin |
| `GET` | `/items/scan/{barcode}/`| Fast barcode lookup for POS scanner | Authenticated |
| `PUT` | `/items/{id}/` | Update product details, prices, alerts | Manager / Admin |
| `DELETE`| `/items/{id}/` | Archive / deactivate product | Admin |
| `POST` | `/items/bulk-import/`| Bulk upload products via CSV/Excel | Admin |
| `GET` | `/categories/` | List categories hierarchy with department grouping | Authenticated |
| `POST` | `/categories/` | Create product category | Manager / Admin |
| `GET` | `/brands/` | List product brands | Authenticated |

### 2.4 Inventory Ledger & Auditing (`/api/inventory/`)
| Method | Endpoint | Description | Permissions |
| :--- | :--- | :--- | :--- |
| `GET` | `/stock/` | Real-time stock levels, low-stock & out-of-stock | Inventory / Manager |
| `POST` | `/adjustments/` | Manual stock count adjustment with reason code | Manager / Admin |
| `GET` | `/movements/` | Immutable stock movement ledger per product | Manager / Admin |
| `GET` | `/alerts/low-stock/`| Products below threshold needing reorder | Authenticated |
| `POST` | `/damages/` | Record damaged/expired stock write-off | Inventory / Manager |

### 2.5 Purchasing & Supply Chain (`/api/purchasing/`)
| Method | Endpoint | Description | Permissions |
| :--- | :--- | :--- | :--- |
| `GET/POST`| `/purchase-orders/`| List and create purchase orders | Manager / Admin |
| `GET` | `/purchase-orders/{id}/`| View purchase order items and status | Manager / Admin |
| `POST` | `/purchase-orders/{id}/receive/`| Receive goods note (GRN), auto-update stock | Inventory / Manager |
| `POST` | `/purchase-orders/{id}/cancel/`| Cancel pending purchase order | Manager / Admin |
| `GET/POST`| `/suppliers/` | Supplier directory & contact management | Manager / Admin |
| `GET` | `/suppliers/{id}/statement/`| Accounts payable ledger & outstanding balances | Accountant / Admin |
| `POST` | `/suppliers/{id}/payments/` | Record payment made to supplier | Accountant / Admin |

### 2.6 Customer CRM & Loyalty (`/api/customers/`)
| Method | Endpoint | Description | Permissions |
| :--- | :--- | :--- | :--- |
| `GET/POST`| `/customers/` | Search and register customer profiles | Cashier / Manager |
| `GET` | `/customers/{id}/` | Customer purchase history & credit balance | Authenticated |
| `POST` | `/customers/{id}/payments/`| Record customer credit debt repayment | Cashier / Manager |
| `GET` | `/customers/{id}/loyalty/` | Loyalty points balance & redemption history | Authenticated |

### 2.7 Expenses & Petty Cash (`/api/expenses/`)
| Method | Endpoint | Description | Permissions |
| :--- | :--- | :--- | :--- |
| `GET/POST`| `/expenses/` | Record operational store expenses with receipt upload| Manager / Accountant|
| `GET` | `/categories/` | Expense categories (Utilities, Rent, Supplies, Waste)| Authenticated |

### 2.8 Reports & Business Intelligence (`/api/reports/`)
| Method | Endpoint | Description | Permissions |
| :--- | :--- | :--- | :--- |
| `GET` | `/dashboard/summary/`| Real-time executive KPIs (Sales, Revenue, Profit, Alerts)| Manager / Admin |
| `GET` | `/daily-sales/` | Daily sales breakdown by hour & cashier | Manager / Admin |
| `GET` | `/profit-loss/` | Gross Profit = Revenue - COGS - Expenses | Accountant / Admin |
| `GET` | `/sales-by-category/`| Revenue distribution across departments | Manager / Admin |
| `GET` | `/sales-by-product/` | Top 20 bestsellers & bottom dead-stock | Manager / Admin |
| `GET` | `/cashier-audit/` | Shift over/short variance analysis per cashier | Manager / Admin |
| `GET` | `/export/pdf/` | Generate styled PDF financial/inventory report | Manager / Admin |
| `GET` | `/export/csv/` | Raw data export for spreadsheet accounting | Manager / Admin |

### 2.9 Offline-First Synchronization (`/api/sync/`)
| Method | Endpoint | Description | Permissions |
| :--- | :--- | :--- | :--- |
| `POST` | `/batch/` | Push queued offline sales, stock counts & movements | Cashier / Terminal |
| `GET` | `/delta/` | Pull catalog changes modified since timestamp `?since=`| Terminal |
