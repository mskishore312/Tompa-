import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../models/company.dart';
import '../widgets/tompa_menu.dart';
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
    return TompaClassicScreen(
      title: 'Select Company',
      children: [
        const TompaHeader(title: 'Select Company', subtitle: 'TOM-PA (Tally On Mobile)'),
        TompaMenuButton(label: 'Create Company', icon: Icons.add_business, onTap: _addCompany),
        const SizedBox(height: 10),
        FutureBuilder<List<Company>>(
          future: _companies,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.white));
            final companies = snapshot.data!;
            if (companies.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No companies created. Use Create Company.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final company in companies)
                  TompaMenuButton(
                    label: company.name,
                    icon: Icons.business,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CompanyWorkspaceScreen(company: company))),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 10),
        TompaMenuButton(label: 'Back', icon: Icons.arrow_back, onTap: () => Navigator.pop(context)),
      ],
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
      backgroundColor: TompaColors.cream,
      title: const Text('Create Company', style: TextStyle(color: TompaColors.green, fontWeight: FontWeight.bold)),
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
          style: FilledButton.styleFrom(backgroundColor: TompaColors.green),
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
