# TOMPA Product Specification

## 1. Purpose
TOMPA is a mobile-first accounting app for Indian small businesses, students, and accounting practitioners who want Tally-like workflows on Android.

The app should be original. It should not copy proprietary app code, UI assets, icons, or protected branding from any other app.

## 2. Core modules

### 2.1 Company Management
- Create company
- Edit company
- Select active company
- Set financial year
- Store GSTIN, address, phone, email, state, and currency
- Maintain multiple companies on one device

### 2.2 Masters

#### Groups
- Assets
- Liabilities
- Income
- Expenses
- Capital
- Sundry Debtors
- Sundry Creditors
- Duties and Taxes
- Bank Accounts
- Cash-in-Hand

#### Ledgers
- Ledger name
- Group
- Opening balance
- Debit/Credit opening nature
- GST registration type
- GSTIN
- Address
- State
- Mobile/email

#### Inventory
- Stock groups
- Stock items
- Units
- HSN/SAC
- GST rate
- Opening stock quantity and value

## 3. Voucher modules

### Accounting vouchers
- Receipt
- Payment
- Contra
- Journal

### Inventory/GST vouchers
- Sales
- Purchase
- Debit note
- Credit note
- GST sales
- GST purchase

Each voucher should support:
- Voucher number
- Date
- Party ledger
- Ledger rows
- Debit/Credit amount
- Narration
- Attachment path for bill/image/PDF
- GST details where applicable

## 4. Reports

### Basic reports
- Day book
- Ledger statement
- Cash book
- Bank book
- Trial balance
- Profit and loss account
- Balance sheet

### GST reports
- GST sales register
- GST purchase register
- GSTR-1 summary
- GSTR-3B summary
- HSN summary

### Exports
- PDF export
- Excel export
- JSON backup
- Future Tally XML export

## 5. Suggested navigation

### Home screen
Cards:
- Companies
- Masters
- Vouchers
- Reports
- GST
- Backup & Export
- Settings

### Master screen
- Groups
- Ledgers
- Stock Items
- Units

### Voucher screen
- Receipt
- Payment
- Contra
- Journal
- Sales
- Purchase
- Debit Note
- Credit Note

### Reports screen
- Day Book
- Ledger Report
- Trial Balance
- Profit & Loss
- Balance Sheet
- GST Reports

## 6. Database design summary

Recommended local database: SQLite.

Tables:
- companies
- groups
- ledgers
- stock_groups
- stock_items
- units
- vouchers
- voucher_entries
- inventory_entries
- tax_entries
- attachments
- app_settings

## 7. Accounting engine rules

Every voucher must satisfy:

Total Debit = Total Credit

Reports should be generated from voucher entries, not from manually stored report totals.

Profit and loss:
- Income credit balances
- Expense debit balances

Balance sheet:
- Assets debit balances
- Liabilities/capital credit balances
- Profit/loss transferred to capital/reserves view

## 8. AI roadmap

Phase 1:
- Narration suggestion
- Ledger suggestion from transaction text

Phase 2:
- Bank statement import and transaction classification
- Duplicate transaction detection

Phase 3:
- Invoice/bill image extraction
- GST classification suggestions
- Auto voucher draft generation

Phase 4:
- Conversational accounting assistant
- Voice voucher entry
- Tally XML export assistant

## 9. MVP acceptance criteria

The first working version should allow the user to:

1. Create a company
2. Create cash, bank, income, expense, debtor, and creditor ledgers
3. Record payment and receipt vouchers
4. Record journal entries
5. View day book
6. View individual ledger report
7. Generate trial balance
8. Export reports as simple files

## 10. Future production concerns

- Data backup and restore
- Multi-device sync
- User login
- Attachment compression
- Audit trail
- Voucher edit history
- Role-based access
- GST validation
- Cloud storage cost control
- AI cost control
