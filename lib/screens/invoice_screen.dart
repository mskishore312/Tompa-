import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../data/app_database.dart';
import '../models/company.dart';
import '../models/invoice.dart';
import '../models/ledger.dart';
import '../services/invoice_posting_service.dart';
import '../services/pdf_invoice_service.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key, required this.company, required this.type});

  final Company company;
  final String type;

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  bool _withInventory = true;
  bool _posting = false;
  List<Ledger> _ledgers = [];
  Ledger? _partyLedger;
  Ledger? _mainLedger;
  Ledger? _gstLedger;
  final _description = TextEditingController();
  final _hsn = TextEditingController();
  final _unit = TextEditingController(text: 'Nos');
  final _qty = TextEditingController(text: '1');
  final _rate = TextEditingController();
  final _gst = TextEditingController(text: '18');
  final List<InvoiceLine> _lines = [];

  @override
  void initState() {
    super.initState();
    _loadLedgers();
  }

  Future<void> _loadLedgers() async {
    final ledgers = await AppDatabase.instance.getLedgers(widget.company.id!);
    setState(() {
      _ledgers = ledgers;
      if (ledgers.isNotEmpty) _partyLedger = ledgers.first;
      _mainLedger = _findGroup(ledgers, widget.type == 'Sales' ? 'Sales' : 'Purchase') ?? (ledgers.isNotEmpty ? ledgers.first : null);
      _gstLedger = _findGroup(ledgers, 'Duties') ?? (ledgers.isNotEmpty ? ledgers.first : null);
    });
  }

  Ledger? _findGroup(List<Ledger> ledgers, String keyword) {
    for (final ledger in ledgers) {
      if (ledger.groupName.toLowerCase().contains(keyword.toLowerCase())) return ledger;
    }
    return null;
  }

  void _addLine() {
    final double rate = double.tryParse(_rate.text.trim()) ?? 0.0;
    final double qty = _withInventory ? (double.tryParse(_qty.text.trim()) ?? 1.0) : 1.0;
    final double gst = double.tryParse(_gst.text.trim()) ?? 0.0;
    if (_description.text.trim().isEmpty || rate <= 0) return;
    setState(() {
      _lines.add(InvoiceLine(description: _description.text.trim(), quantity: qty, rate: rate, gstRate: gst, hsn: _withInventory ? _hsn.text.trim() : null, unit: _withInventory ? _unit.text.trim() : null));
      _description.clear();
      _hsn.clear();
      _rate.clear();
    });
  }

  InvoiceDraft _draft() => InvoiceDraft(
    type: widget.type,
    withInventory: _withInventory,
    partyName: _partyLedger?.name ?? 'Party',
    date: DateTime.now(),
    invoiceNumber: 'AUTO',
    lines: _lines,
  );

  Future<void> _postInvoice() async {
    if (_lines.isEmpty || _partyLedger == null || _mainLedger == null || _gstLedger == null) return;
    setState(() => _posting = true);
    try {
      await const InvoicePostingService().postInvoice(company: widget.company, invoice: _draft(), partyLedger: _partyLedger!, mainLedger: _mainLedger!, gstLedger: _gstLedger!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice posted to accounts')));
      setState(() {
        _lines.clear();
        _posting = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _posting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _previewPdf() async {
    if (_lines.isEmpty) return;
    final draft = _draft();
    await Printing.layoutPdf(onLayout: (_) => const PdfInvoiceService().buildInvoicePdf(company: widget.company, invoice: draft));
  }

  @override
  void dispose() {
    _description.dispose();
    _hsn.dispose();
    _unit.dispose();
    _qty.dispose();
    _rate.dispose();
    _gst.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = _draft();
    return Scaffold(
      appBar: AppBar(title: Text('${widget.type} Invoice')),
      body: _ledgers.length < 3
          ? const Center(child: Text('Create party, sales/purchase, and GST ledgers before posting invoice.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('With Inventory'), icon: Icon(Icons.inventory_2)),
                    ButtonSegment(value: false, label: Text('Without Inventory'), icon: Icon(Icons.description)),
                  ],
                  selected: {_withInventory},
                  onSelectionChanged: (value) => setState(() => _withInventory = value.first),
                ),
                DropdownButtonFormField<Ledger>(
                  value: _partyLedger,
                  decoration: const InputDecoration(labelText: 'Party ledger'),
                  items: _ledgers.map((ledger) => DropdownMenuItem(value: ledger, child: Text(ledger.name))).toList(),
                  onChanged: (value) => setState(() => _partyLedger = value),
                ),
                DropdownButtonFormField<Ledger>(
                  value: _mainLedger,
                  decoration: InputDecoration(labelText: widget.type == 'Sales' ? 'Sales ledger' : 'Purchase ledger'),
                  items: _ledgers.map((ledger) => DropdownMenuItem(value: ledger, child: Text('${ledger.name} (${ledger.groupName})'))).toList(),
                  onChanged: (value) => setState(() => _mainLedger = value),
                ),
                DropdownButtonFormField<Ledger>(
                  value: _gstLedger,
                  decoration: const InputDecoration(labelText: 'GST ledger'),
                  items: _ledgers.map((ledger) => DropdownMenuItem(value: ledger, child: Text('${ledger.name} (${ledger.groupName})'))).toList(),
                  onChanged: (value) => setState(() => _gstLedger = value),
                ),
                TextField(controller: _description, decoration: InputDecoration(labelText: _withInventory ? 'Item name' : 'Service / ledger description')),
                if (_withInventory) TextField(controller: _hsn, decoration: const InputDecoration(labelText: 'HSN')),
                if (_withInventory) TextField(controller: _qty, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity')),
                if (_withInventory) TextField(controller: _unit, decoration: const InputDecoration(labelText: 'Unit')),
                TextField(controller: _rate, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Rate / taxable amount')),
                TextField(controller: _gst, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'GST rate %')),
                const SizedBox(height: 12),
                FilledButton.icon(onPressed: _addLine, icon: const Icon(Icons.add), label: const Text('Add Line')),
                const Divider(),
                ..._lines.map((line) => ListTile(title: Text(line.description), subtitle: Text(_withInventory ? 'Qty ${line.quantity} ${line.unit ?? ''} • GST ${line.gstRate}%' : 'GST ${line.gstRate}%'), trailing: Text('₹${line.total.toStringAsFixed(2)}'))),
                const Divider(),
                ListTile(title: const Text('Taxable Value'), trailing: Text('₹${draft.taxableValue.toStringAsFixed(2)}')),
                ListTile(title: const Text('GST'), trailing: Text('₹${draft.gstAmount.toStringAsFixed(2)}')),
                ListTile(title: const Text('Total'), trailing: Text('₹${draft.total.toStringAsFixed(2)}')),
                const SizedBox(height: 16),
                FilledButton.icon(onPressed: _posting ? null : _postInvoice, icon: const Icon(Icons.save), label: Text(_posting ? 'Posting...' : 'Save & Post Invoice')),
                const SizedBox(height: 8),
                OutlinedButton.icon(onPressed: _previewPdf, icon: const Icon(Icons.picture_as_pdf), label: const Text('Preview / Export PDF')),
              ],
            ),
    );
  }
}
