import 'package:flutter/material.dart';

import '../models/company.dart';
import '../widgets/tompa_menu.dart';
import 'backup_screen.dart';
import 'invoice_screen.dart';
import 'ledger_screen.dart';
import 'reports_screen.dart';
import 'voucher_screen.dart';

class CompanyWorkspaceScreen extends StatelessWidget {
  const CompanyWorkspaceScreen({super.key, required this.company});

  final Company company;

  @override
  Widget build(BuildContext context) {
    return TompaClassicScreen(
      title: 'Gateway',
      children: [
        TompaHeader(title: 'Gateway', subtitle: company.name),
        TompaMenuButton(label: 'Masters', icon: Icons.account_tree, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LedgerScreen(company: company)))),
        TompaMenuButton(label: 'Accounting Vouchers', icon: Icons.receipt_long, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VoucherScreen(company: company)))),
        TompaMenuButton(label: 'Sales Invoice', icon: Icons.sell, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InvoiceScreen(company: company, type: 'Sales')))),
        TompaMenuButton(label: 'Purchase Invoice', icon: Icons.shopping_cart, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InvoiceScreen(company: company, type: 'Purchase')))),
        TompaMenuButton(label: 'Reports', icon: Icons.bar_chart, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReportsScreen(company: company)))),
        TompaMenuButton(label: 'Registers', icon: Icons.list_alt, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReportsScreen(company: company)))),
        TompaMenuButton(label: 'GST Reports', icon: Icons.percent, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReportsScreen(company: company)))),
        TompaMenuButton(label: 'Utility', icon: Icons.build, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BackupScreen(company: company)))),
        TompaMenuButton(label: 'Back', icon: Icons.arrow_back, onTap: () => Navigator.pop(context)),
      ],
    );
  }
}
