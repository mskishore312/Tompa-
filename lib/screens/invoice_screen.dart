import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../models/company.dart';
import '../models/invoice.dart';
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
  final _party = TextEditingController();
  final _description = TextEditingController();
  final _hsn = TextEditingController();
  final _unit = TextEditingController(text: 'Nos');
  final _qty = TextEditingController(text: '1');
  final _rate = TextEditingController();
  final _gst = TextEditingController(text: '18');
  final List<InvoiceLine> _lines = [];

  void _addLine() {
    final rate = double.tryParse(_rate.text.trim()) ?? 0;
    final qty = _withInventory ? (double.tryParse(_qty.text.trim()) ?? 1) : 1;
    final gst = double.tryParse(_gst.text.trim()) ?? 0;
    if (_description.text.trim().isEmpty || rate <= 0) return;
    setState(() {
      _lines.add(InvoiceLine(
        description: _description.text.trim(),
        quantity: qty,
        rate: rate,
        gstRate: gst,
        hsn: _withInventory ? _hsn.text.trim() : null,
        unit: _withInventory ? _unit.text.trim() : null,
      ));
      _description.clear();
      _hsn.clear();
      _rate.clear();
    });
  }

  InvoiceDraft _draft() => InvoiceDraft(
    type: widget.type,
    withInventory: _withInventory,
    partyName: _party.text.trim().isEmpty ? 'Party' : _party.text.trim(),
    date: DateTime.now(),
    invoiceNumber: 'AUTO',
    lines: _lines,
  );

  Future<void> _previewPdf() async {
    if (_lines.isEmpty) return;
    final draft = _draft();
    await Printing.layoutPdf(onLayout: (_) => const PdfInvoiceService().buildInvoicePdf(company: widget.company, invoice: draft));
  }

  @override
  void dispose() {
    _party.dispose();
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
      body: ListView(
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
          TextField(controller: _party, decoration: const InputDecoration(labelText: 'Party name')),
          TextField(controller: _description, decoration: InputDecoration(labelText: _withInventory ? 'Item name' : 'Service / ledger description')),
          if (_withInventory) TextField(controller: _hsn, decoration: const InputDecoration(labelText: 'HSN')),
          if (_withInventory) TextField(controller: _qty, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity')),
          if (_withInventory) TextField(controller: _unit, decoration: const InputDecoration(labelText: 'Unit')),
          TextField(controller: _rate, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Rate / taxable amount')),
          TextField(controller: _gst, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'GST rate %')),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: _addLine, icon: const Icon(Icons.add), label: const Text('Add Line')),
          const Divider(),
          ..._lines.map((line) => ListTile(
            title: Text(line.description),
            subtitle: Text(_withInventory ? 'Qty ${line.quantity} ${line.unit ?? ''} • GST ${line.gstRate}%' : 'GST ${line.gstRate}%'),
            trailing: Text('₹${line.total.toStringAsFixed(2)}'),
          )),
          const Divider(),
          ListTile(title: const Text('Taxable Value'), trailing: Text('₹${draft.taxableValue.toStringAsFixed(2)}')),
          ListTile(title: const Text('GST'), trailing: Text('₹${draft.gstAmount.toStringAsFixed(2)}')),
          ListTile(title: const Text('Total'), trailing: Text('₹${draft.total.toStringAsFixed(2)}')),
          const SizedBox(height: 16),
          FilledButton.icon(onPressed: _previewPdf, icon: const Icon(Icons.picture_as_pdf), label: const Text('Preview / Export PDF')),
        ],
      ),
    );
  }
}
