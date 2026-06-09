import 'package:flutter/material.dart';

import '../models/company.dart';
import 'backup_screen.dart';
import 'ledger_screen.dart';
import 'reports_screen.dart';
import 'voucher_screen.dart';

class CompanyWorkspaceScreen extends StatelessWidget {
  const CompanyWorkspaceScreen({super.key, required this.company});

  final Company company;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(company.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Tile(
            icon: Icons.account_balance_wallet,
            title: 'Ledgers',
            subtitle: 'Create and view account ledgers',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LedgerScreen(company: company))),
          ),
          _Tile(
            icon: Icons.receipt_long,
            title: 'Vouchers',
            subtitle: 'Post receipt, payment, contra, journal, sales and purchase entries',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VoucherScreen(company: company))),
          ),
          _Tile(
            icon: Icons.bar_chart,
            title: 'Reports',
            subtitle: 'Day book, trial balance, P&L, balance sheet and GST summary',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReportsScreen(company: company))),
          ),
          _Tile(
            icon: Icons.backup,
            title: 'Backup & Export',
            subtitle: 'Generate JSON backup for the company data',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BackupScreen(company: company))),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
