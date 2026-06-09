import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../models/company.dart';
import '../models/ledger.dart';
import '../models/voucher.dart';

class VoucherScreen extends StatefulWidget {
  const VoucherScreen({super.key, required this.company});

  final Company company;

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  List<Ledger> _ledgers = [];
  Ledger? _debitLedger;
  Ledger? _creditLedger;
  String _type = 'Journal';
  final _amount = TextEditingController();
  final _gstRate = TextEditingController(text: '0');
  final _narration = TextEditingController();

  bool get _isGstVoucher => _type == 'Sales' || _type == 'Purchase';

  @override
  void initState() {
    super.initState();
    _loadLedgers();
  }

  Future<void> _loadLedgers() async {
    final ledgers = await AppDatabase.instance.getLedgers(widget.company.id!);
    setState(() {
      _ledgers = ledgers;
      if (ledgers.isNotEmpty) _debitLedger = ledgers.first;
      if (ledgers.length > 1) _creditLedger = ledgers[1];
    });
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amount.text.trim()) ?? 0;
    final gstRate = double.tryParse(_gstRate.text.trim()) ?? 0;
    final tax = _isGstVoucher ? amount * gstRate / 100 : 0.0;
    final totalAmount = amount + tax;
    final cgst = _isGstVoucher ? tax / 2 : 0.0;
    final sgst = _isGstVoucher ? tax / 2 : 0.0;

    if (_debitLedger == null || _creditLedger == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select ledgers and enter amount')));
      return;
    }
    if (_debitLedger!.id == _creditLedger!.id) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debit and credit ledger cannot be same')));
      return;
    }

    final voucher = Voucher(
      companyId: widget.company.id!,
      type: _type,
      date: DateTime.now(),
      narration: _narration.text.trim(),
      taxableValue: _isGstVoucher ? amount : 0,
      gstRate: _isGstVoucher ? gstRate : 0,
      cgst: cgst,
      sgst: sgst,
    );
    final entries = [
      VoucherEntry(ledgerId: _debitLedger!.id!, ledgerName: _debitLedger!.name, dr: totalAmount, cr: 0),
      VoucherEntry(ledgerId: _creditLedger!.id!, ledgerName: _creditLedger!.name, dr: 0, cr: totalAmount),
    ];
    await AppDatabase.instance.insertVoucher(voucher, entries);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Voucher saved')));
    _amount.clear();
    _narration.clear();
  }

  @override
  void dispose() {
    _amount.dispose();
    _gstRate.dispose();
    _narration.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.company.name} - Voucher')),
      body: _ledgers.length < 2
          ? const Center(child: Text('Create at least two ledgers before entering vouchers.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<String>(
                  value: _type,
                  decoration: const InputDecoration(labelText: 'Voucher type'),
                  items: const ['Receipt', 'Payment', 'Contra', 'Journal', 'Sales', 'Purchase']
                      .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) => setState(() => _type = value!),
                ),
                DropdownButtonFormField<Ledger>(
                  value: _debitLedger,
                  decoration: const InputDecoration(labelText: 'Debit ledger'),
                  items: _ledgers.map((l) => DropdownMenuItem(value: l, child: Text(l.name))).toList(),
                  onChanged: (value) => setState(() => _debitLedger = value),
                ),
                DropdownButtonFormField<Ledger>(
                  value: _creditLedger,
                  decoration: const InputDecoration(labelText: 'Credit ledger'),
                  items: _ledgers.map((l) => DropdownMenuItem(value: l, child: Text(l.name))).toList(),
                  onChanged: (value) => setState(() => _creditLedger = value),
                ),
                TextField(controller: _amount, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: _isGstVoucher ? 'Taxable value' : 'Amount')),
                if (_isGstVoucher) TextField(controller: _gstRate, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'GST rate %')),
                TextField(controller: _narration, decoration: const InputDecoration(labelText: 'Narration')),
                const SizedBox(height: 24),
                FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text('Save Voucher')),
              ],
            ),
    );
  }
}
