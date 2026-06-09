# TOMPA

TOMPA is an original mobile accounting app concept inspired by common Indian small-business accounting workflows.

## Goal
Build a Tally-style mobile accounting app with:

- Company creation and financial-year management
- Ledger and group masters
- Stock item, stock group, and unit masters
- Receipt, payment, contra, journal, sales, purchase, debit note, and credit note vouchers
- GST sales and purchase registers
- Day book, ledger report, trial balance, profit and loss account, and balance sheet
- PDF/Excel export
- Tally-compatible export planning
- Future AI-assisted voucher entry and document extraction

## Important note
This repository is not intended to copy any proprietary app code, assets, or branding. It should be developed as an original implementation using clean architecture and independently written code.

## Proposed stack

- Flutter for Android/iOS UI
- SQLite for offline local accounting database
- Optional Supabase/Firebase later for sync and login
- PDF and Excel export packages
- AI service layer for narration understanding, bill extraction, and ledger suggestion

## Suggested MVP

1. Create company
2. Create ledger
3. Record payment/receipt/journal vouchers
4. View day book and ledger report
5. Generate trial balance
6. Export basic reports

See `docs/PRODUCT_SPEC.md` for the detailed feature plan.