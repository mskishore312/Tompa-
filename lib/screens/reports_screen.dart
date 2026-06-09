import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../models/company.dart';
import '../models/voucher.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key, required this.company});

  final Company company;

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late Future<List<VoucherWithEntries>> _dayBook;
  late Future<List<Map<String, Object?>>> _trialBalance;
  late Future<List<Map<String, Object?>>> _profitAndLoss;
  late Future<List<Map<String, Object?>>> _balanceSheet;
  late Future<Map<String, double>> _gstSummary;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _dayBook = AppDatabase.instance.getVouchers(widget.company.id!);
    _trialBalance = AppDatabase.instance.getTrialBalance(widget.company.id!);
    _profitAndLoss = AppDatabase.instance.getProfitAndLoss(widget.company.id!);
    _balanceSheet = AppDatabase.instance.getBalanceSheet(widget.company.id!);
    _gstSummary = AppDatabase.instance.getGstSummary(widget.company.id!);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.company.name} - Reports'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [Tab(text: 'Day Book'), Tab(text: 'Trial Balance'), Tab(text: 'P&L'), Tab(text: 'Balance Sheet'), Tab(text: 'GST')],
          ),
        ),
        body: TabBarView(
          children: [
            _DayBook(future: _dayBook),
            _LedgerBalanceReport(title: 'Trial Balance', future: _trialBalance),
            _LedgerBalanceReport(title: 'Profit & Loss', future: _profitAndLoss),
            _LedgerBalanceReport(title: 'Balance Sheet', future: _balanceSheet),
            _GstSummary(future: _gstSummary),
          ],
        ),
      ),
    );
  }
}

class _DayBook extends StatelessWidget {
  const _DayBook({required this.future});

  final Future<List<VoucherWithEntries>> future;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<VoucherWithEntries>>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final vouchers = snapshot.data!;
        if (vouchers.isEmpty) return const Center(child: Text('No vouchers yet.'));
        return ListView.separated(
          itemCount: vouchers.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = vouchers[index];
            final amount = item.entries.fold<double>(0, (sum, e) => sum + e.dr);
            return ListTile(
              title: Text('${item.voucher.type} - ₹${amount.toStringAsFixed(2)}'),
              subtitle: Text(item.entries.map((e) => '${e.ledgerName} Dr ${e.dr} Cr ${e.cr}').join('\n')),
              isThreeLine: true,
            );
          },
        );
      },
    );
  }
}

class _LedgerBalanceReport extends StatelessWidget {
  const _LedgerBalanceReport({required this.title, required this.future});

  final String title;
  final Future<List<Map<String, Object?>>> future;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, Object?>>>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final rows = snapshot.data!;
        if (rows.isEmpty) return Center(child: Text('No data for $title yet.'));
        double totalDr = 0;
        double totalCr = 0;
        for (final row in rows) {
          totalDr += (row['debit'] as num).toDouble();
          totalCr += (row['credit'] as num).toDouble();
        }
        return ListView(
          children: [
            ...rows.map((row) {
              final dr = (row['debit'] as num).toDouble();
              final cr = (row['credit'] as num).toDouble();
              return ListTile(
                title: Text(row['name'] as String),
                subtitle: Text(row['group_name'] as String),
                trailing: Text('Dr ${dr.toStringAsFixed(2)}\nCr ${cr.toStringAsFixed(2)}'),
              );
            }),
            const Divider(),
            ListTile(
              title: const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: Text('Dr ${totalDr.toStringAsFixed(2)}\nCr ${totalCr.toStringAsFixed(2)}'),
            ),
          ],
        );
      },
    );
  }
}

class _GstSummary extends StatelessWidget {
  const _GstSummary({required this.future});

  final Future<Map<String, double>> future;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, double>>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final data = snapshot.data!;
        final totalTax = data['cgst']! + data['sgst']! + data['igst']!;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _AmountTile(label: 'Taxable Value', amount: data['taxable']!),
            _AmountTile(label: 'CGST', amount: data['cgst']!),
            _AmountTile(label: 'SGST', amount: data['sgst']!),
            _AmountTile(label: 'IGST', amount: data['igst']!),
            const Divider(),
            _AmountTile(label: 'Total GST', amount: totalTax, bold: true),
          ],
        );
      },
    );
  }
}

class _AmountTile extends StatelessWidget {
  const _AmountTile({required this.label, required this.amount, this.bold = false});

  final String label;
  final double amount;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label, style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null),
      trailing: Text('₹${amount.toStringAsFixed(2)}', style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null),
    );
  }
}
