import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../models/company.dart';
import '../models/ledger.dart';
import '../widgets/tompa_menu.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key, required this.company});

  final Company company;

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  late Future<List<Ledger>> _ledgers;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _ledgers = AppDatabase.instance.getLedgers(widget.company.id!);
  }

  Future<void> _addLedger() async {
    final ledger = await showDialog<Ledger>(context: context, builder: (_) => LedgerDialog(companyId: widget.company.id!));
    if (ledger == null) return;
    await AppDatabase.instance.insertLedger(ledger);
    setState(_reload);
  }

  @override
  Widget build(BuildContext context) {
    return TompaClassicScreen(
      title: 'Masters',
      children: [
        TompaHeader(title: 'Masters', subtitle: widget.company.name),
        TompaMenuButton(label: 'Create Ledger', icon: Icons.add, onTap: _addLedger),
        FutureBuilder<List<Ledger>>(
          future: _ledgers,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.white));
            final ledgers = snapshot.data!;
            if (ledgers.isEmpty) return const Padding(padding: EdgeInsets.all(16), child: Text('No ledgers yet. Use Create Ledger.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)));
            return Column(
              children: ledgers.map((ledger) => Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 5),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: TompaColors.cream, border: Border.all(color: Colors.white, width: 1.5)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(ledger.name, style: const TextStyle(color: TompaColors.green, fontSize: 17, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text('${ledger.groupName} • Opening ${ledger.openingBalance.toStringAsFixed(2)} ${ledger.openingType}', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                ]),
              )).toList(),
            );
          },
        ),
        const SizedBox(height: 12),
        TompaMenuButton(label: 'Back', icon: Icons.arrow_back, onTap: () => Navigator.pop(context)),
      ],
    );
  }
}

class LedgerDialog extends StatefulWidget {
  const LedgerDialog({super.key, required this.companyId});

  final int companyId;

  @override
  State<LedgerDialog> createState() => _LedgerDialogState();
}

class _LedgerDialogState extends State<LedgerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _opening = TextEditingController(text: '0');
  String _group = 'Cash-in-Hand';
  String _type = 'Dr';

  final _groups = const ['Cash-in-Hand', 'Bank Accounts', 'Sundry Debtors', 'Sundry Creditors', 'Sales Accounts', 'Purchase Accounts', 'Direct Expenses', 'Indirect Expenses', 'Duties and Taxes', 'Capital Account'];

  @override
  void dispose() {
    _name.dispose();
    _opening.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: TompaColors.cream,
      title: const Text('Create Ledger', style: TextStyle(color: TompaColors.green, fontWeight: FontWeight.bold)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Ledger name'), validator: (value) => value == null || value.trim().isEmpty ? 'Enter ledger name' : null),
            DropdownButtonFormField<String>(initialValue: _group, decoration: const InputDecoration(labelText: 'Group'), items: _groups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(), onChanged: (value) => setState(() => _group = value!)),
            TextFormField(controller: _opening, decoration: const InputDecoration(labelText: 'Opening balance'), keyboardType: TextInputType.number),
            DropdownButtonFormField<String>(initialValue: _type, decoration: const InputDecoration(labelText: 'Opening type'), items: const [DropdownMenuItem(value: 'Dr', child: Text('Debit')), DropdownMenuItem(value: 'Cr', child: Text('Credit'))], onChanged: (value) => setState(() => _type = value!)),
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: TompaColors.green),
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(context, Ledger(companyId: widget.companyId, name: _name.text.trim(), groupName: _group, openingBalance: double.tryParse(_opening.text.trim()) ?? 0, openingType: _type));
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
