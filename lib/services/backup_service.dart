import 'dart:convert';

import '../data/app_database.dart';
import '../models/company.dart';
import '../models/ledger.dart';
import '../models/voucher.dart';

class BackupService {
  const BackupService();

  Future<String> buildCompanyBackup(Company company) async {
    final ledgers = await AppDatabase.instance.getLedgers(company.id!);
    final vouchers = await AppDatabase.instance.getVouchers(company.id!);

    final data = {
      'app': 'TOMPA',
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'company': company.toMap(),
      'ledgers': ledgers.map((ledger) => ledger.toMap()).toList(),
      'vouchers': vouchers.map(_voucherToMap).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Map<String, Object?> _voucherToMap(VoucherWithEntries item) {
    return {
      'voucher': item.voucher.toMap(),
      'entries': item.entries.map((entry) => entry.toMap(item.voucher.id ?? 0)).toList(),
    };
  }
}
