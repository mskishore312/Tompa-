import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/company.dart';
import '../models/ledger.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tompa.db');
    _db = await openDatabase(path, version: 1, onCreate: _createDb);
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
    final rows = await db.query(
      'ledgers',
      where: 'company_id = ?',
      whereArgs: [companyId],
      orderBy: 'name',
    );
    return rows.map(Ledger.fromMap).toList();
  }
}
