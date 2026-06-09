class Voucher {
  const Voucher({this.id, required this.companyId, required this.type, required this.date, required this.narration});

  final int? id;
  final int companyId;
  final String type;
  final DateTime date;
  final String narration;

  Map<String, Object?> toMap() => {
    'id': id,
    'company_id': companyId,
    'type': type,
    'date': date.toIso8601String(),
    'narration': narration,
  };

  factory Voucher.fromMap(Map<String, Object?> map) => Voucher(
    id: map['id'] as int?,
    companyId: map['company_id'] as int,
    type: map['type'] as String,
    date: DateTime.parse(map['date'] as String),
    narration: map['narration'] as String,
  );
}

class VoucherEntry {
  const VoucherEntry({this.id, this.voucherId, required this.ledgerId, required this.ledgerName, required this.dr, required this.cr});

  final int? id;
  final int? voucherId;
  final int ledgerId;
  final String ledgerName;
  final double dr;
  final double cr;

  Map<String, Object?> toMap(int parentVoucherId) => {
    'id': id,
    'voucher_id': parentVoucherId,
    'ledger_id': ledgerId,
    'ledger_name': ledgerName,
    'dr': dr,
    'cr': cr,
  };

  factory VoucherEntry.fromMap(Map<String, Object?> map) => VoucherEntry(
    id: map['id'] as int?,
    voucherId: map['voucher_id'] as int?,
    ledgerId: map['ledger_id'] as int,
    ledgerName: map['ledger_name'] as String,
    dr: (map['dr'] as num).toDouble(),
    cr: (map['cr'] as num).toDouble(),
  );
}

class VoucherWithEntries {
  const VoucherWithEntries({required this.voucher, required this.entries});

  final Voucher voucher;
  final List<VoucherEntry> entries;
}
