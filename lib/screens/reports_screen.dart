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

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _dayBook = AppDatabase.instance.getVouchers(widget.company.id!);
    _trialBalance = AppDatabase.instance.getTrialBalance(widget.company.id!);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.company.name} - Reports'),
          bottom: const TabBar(tabs: [Tab(text: 'Day Book'), Tab(text: 'Trial Balance')]),
        ),
        body: TabBarView(children: [_DayBook(future: _dayBook), _TrialBalance(future: _trialBalance)]),
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

class _TrialBalance extends StatelessWidget {
  const _TrialBalance({required this.future});

  final Future<List<Map<String, Object?>>> future;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, Object?>>>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final rows = snapshot.data!;
        if (rows.isEmpty) return const Center(child: Text('No ledger balances yet.'));
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
