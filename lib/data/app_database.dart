import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/company.dart';
import '../models/ledger.dart';
import '../models/voucher.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tompa.db');
    _db = await openDatabase(path, version: 2, onCreate: _createDb, onUpgrade: _upgradeDb);
    return _db!;
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE companies(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        from_date TEXT NOT NULL,
        to_date TEXT NOT NULL,
        gstin TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE ledgers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        company_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        group_name TEXT NOT NULL,
        opening_balance REAL NOT NULL DEFAULT 0,
        opening_type TEXT NOT NULL DEFAULT 'Dr',
        FOREIGN KEY(company_id) REFERENCES companies(id)
      )
    ''');
    await _createVoucherTables(db);
  }

  Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) await _createVoucherTables(db);
  }

  Future<void> _createVoucherTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS vouchers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        company_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        date TEXT NOT NULL,
        narration TEXT NOT NULL,
        FOREIGN KEY(company_id) REFERENCES companies(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS voucher_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        voucher_id INTEGER NOT NULL,
        ledger_id INTEGER NOT NULL,
        ledger_name TEXT NOT NULL,
        dr REAL NOT NULL DEFAULT 0,
        cr REAL NOT NULL DEFAULT 0,
        FOREIGN KEY(voucher_id) REFERENCES vouchers(id),
        FOREIGN KEY(ledger_id) REFERENCES ledgers(id)
      )
    ''');
  }

  Future<int> insertCompany(Company company) async {
    final db = await database;
    return db.insert('companies', company.toMap());
  }

  Future<List<Company>> getCompanies() async {
    final db = await database;
    final rows = await db.query('companies', orderBy: 'name');
    return rows.map(Company.fromMap).toList();
  }

  Future<int> insertLedger(Ledger ledger) async {
    final db = await database;
    return db.insert('ledgers', ledger.toMap());
  }

  Future<List<Ledger>> getLedgers(int companyId) async {
    final db = await database;
    final rows = await db.query('ledgers', where: 'company_id = ?', whereArgs: [companyId], orderBy: 'name');
    return rows.map(Ledger.fromMap).toList();
  }

  Future<int> insertVoucher(Voucher voucher, List<VoucherEntry> entries) async {
    final debit = entries.fold<double>(0, (sum, entry) => sum + entry.dr);
    final credit = entries.fold<double>(0, (sum, entry) => sum + entry.cr);
    if ((debit - credit).abs() > 0.01) throw Exception('Voucher is not balanced');

    final db = await database;
    return db.transaction((txn) async {
      final voucherId = await txn.insert('vouchers', voucher.toMap());
      for (final entry in entries) {
        await txn.insert('voucher_entries', entry.toMap(voucherId));
      }
      return voucherId;
    });
  }

  Future<List<VoucherWithEntries>> getVouchers(int companyId) async {
    final db = await database;
    final voucherRows = await db.query('vouchers', where: 'company_id = ?', whereArgs: [companyId], orderBy: 'date DESC, id DESC');
    final result = <VoucherWithEntries>[];
    for (final row in voucherRows) {
      final voucher = Voucher.fromMap(row);
      final entryRows = await db.query('voucher_entries', where: 'voucher_id = ?', whereArgs: [voucher.id], orderBy: 'id');
      result.add(VoucherWithEntries(voucher: voucher, entries: entryRows.map(VoucherEntry.fromMap).toList()));
    }
    return result;
  }

  Future<List<Map<String, Object?>>> getTrialBalance(int companyId) async {
    final db = await database;
    return db.rawQuery('''
      SELECT l.name, l.group_name,
        CASE WHEN l.opening_type = 'Dr' THEN l.opening_balance ELSE 0 END + IFNULL(SUM(e.dr), 0) AS debit,
        CASE WHEN l.opening_type = 'Cr' THEN l.opening_balance ELSE 0 END + IFNULL(SUM(e.cr), 0) AS credit
      FROM ledgers l
      LEFT JOIN voucher_entries e ON e.ledger_id = l.id
      WHERE l.company_id = ?
      GROUP BY l.id, l.name, l.group_name, l.opening_balance, l.opening_type
      ORDER BY l.name
    ''', [companyId]);
  }
}
