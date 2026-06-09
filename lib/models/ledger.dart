class Ledger {
  const Ledger({
    this.id,
    required this.companyId,
    required this.name,
    required this.groupName,
    required this.openingBalance,
    required this.openingType,
  });

  final int? id;
  final int companyId;
  final String name;
  final String groupName;
  final double openingBalance;
  final String openingType;

  Map<String, Object?> toMap() => {
    'id': id,
    'company_id': companyId,
    'name': name,
    'group_name': groupName,
    'opening_balance': openingBalance,
    'opening_type': openingType,
  };

  factory Ledger.fromMap(Map<String, Object?> map) => Ledger(
    id: map['id'] as int?,
    companyId: map['company_id'] as int,
    name: map['name'] as String,
    groupName: map['group_name'] as String,
    openingBalance: (map['opening_balance'] as num).toDouble(),
    openingType: map['opening_type'] as String,
  );
}
