import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../models/company.dart';
import 'company_workspace_screen.dart';

class CompanyScreen extends StatefulWidget {
  const CompanyScreen({super.key});

  @override
  State<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {
  late Future<List<Company>> _companies;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _companies = AppDatabase.instance.getCompanies();
  }

  Future<void> _addCompany() async {
    final result = await showDialog<Company>(context: context, builder: (_) => const CompanyDialog());
    if (result == null) return;
    await AppDatabase.instance.insertCompany(result);
    setState(_reload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Companies')),
      floatingActionButton: FloatingActionButton.extended(onPressed: _addCompany, icon: const Icon(Icons.add_business), label: const Text('Company')),
      body: FutureBuilder<List<Company>>(
        future: _companies,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final companies = snapshot.data!;
          if (companies.isEmpty) return const Center(child: Text('No companies yet. Tap + Company to create one.'));
          return ListView.separated(
            itemCount: companies.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final company = companies[index];
              return ListTile(
                leading: const Icon(Icons.business),
                title: Text(company.name),
                subtitle: Text('FY ${company.fromDate.year}-${company.toDate.year}${company.gstin == null ? '' : ' • GSTIN ${company.gstin}'}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CompanyWorkspaceScreen(company: company))),
              );
            },
          );
        },
      ),
    );
  }
}

class CompanyDialog extends StatefulWidget {
  const CompanyDialog({super.key});

  @override
  State<CompanyDialog> createState() => _CompanyDialogState();
}

class _CompanyDialogState extends State<CompanyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _gstin = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _gstin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Company'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Company name'), validator: (value) => value == null || value.trim().isEmpty ? 'Enter company name' : null),
            TextFormField(controller: _gstin, decoration: const InputDecoration(labelText: 'GSTIN optional')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(context, Company(name: _name.text.trim(), fromDate: DateTime(DateTime.now().year, 4, 1), toDate: DateTime(DateTime.now().year + 1, 3, 31), gstin: _gstin.text.trim().isEmpty ? null : _gstin.text.trim()));
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
