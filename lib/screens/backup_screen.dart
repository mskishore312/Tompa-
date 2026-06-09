import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/company.dart';
import '../services/backup_service.dart';
import '../services/csv_export_service.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key, required this.company});

  final Company company;

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  String? _json;
  String? _csv;
  bool _loading = false;

  Future<void> _generateBackup() async {
    setState(() => _loading = true);
    final json = await const BackupService().buildCompanyBackup(widget.company);
    if (!mounted) return;
    setState(() {
      _json = json;
      _loading = false;
    });
  }

  Future<void> _generateCsv() async {
    final csv = await const CsvExportService().buildTrialBalanceCsv(widget.company.id!);
    if (!mounted) return;
    setState(() => _csv = csv);
  }

  Future<void> _copyText(String text, String message) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.company.name} - Backup')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Export company data as JSON backup and Trial Balance as CSV.'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _loading ? null : _generateBackup,
            icon: const Icon(Icons.backup),
            label: Text(_loading ? 'Generating...' : 'Generate JSON Backup'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _json == null ? null : () => _copyText(_json!, 'Backup JSON copied'),
            icon: const Icon(Icons.copy),
            label: const Text('Copy Backup JSON'),
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: _generateCsv,
            icon: const Icon(Icons.table_chart),
            label: const Text('Generate Trial Balance CSV'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _csv == null ? null : () => _copyText(_csv!, 'CSV copied'),
            icon: const Icon(Icons.copy_all),
            label: const Text('Copy CSV'),
          ),
          const SizedBox(height: 16),
          if (_csv != null) ...[
            Text('Trial Balance CSV', style: Theme.of(context).textTheme.titleMedium),
            SelectableText(_csv!, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            const Divider(),
          ],
          if (_json != null) ...[
            Text('JSON Backup', style: Theme.of(context).textTheme.titleMedium),
            SelectableText(_json!, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
          ],
        ],
      ),
    );
  }
}
