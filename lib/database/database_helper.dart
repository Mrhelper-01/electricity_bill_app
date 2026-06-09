import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/bill_record.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('electricity_bill.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        month TEXT NOT NULL UNIQUE,
        units REAL NOT NULL,
        rebate_percent REAL NOT NULL,
        total_charges REAL NOT NULL,
        final_cost REAL NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertBill(BillRecord bill) async {
    final db = await database;
    return await db.insert('bills', bill.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail);
  }

  Future<List<BillRecord>> getAllBills() async {
    final db = await database;
    final monthOrder = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final maps = await db.query('bills');
    final list = maps.map((m) => BillRecord.fromMap(m)).toList();
    list.sort((a, b) =>
        monthOrder.indexOf(a.month).compareTo(monthOrder.indexOf(b.month)));
    return list;
  }

  Future<BillRecord?> getBillById(int id) async {
    final db = await database;
    final maps = await db.query('bills', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return BillRecord.fromMap(maps.first);
  }

  Future<BillRecord?> getBillByMonth(String month) async {
    final db = await database;
    final maps =
        await db.query('bills', where: 'month = ?', whereArgs: [month]);
    if (maps.isEmpty) return null;
    return BillRecord.fromMap(maps.first);
  }

  Future<int> updateBill(BillRecord bill) async {
    final db = await database;
    return await db
        .update('bills', bill.toMap(), where: 'id = ?', whereArgs: [bill.id]);
  }

  Future<int> deleteBill(int id) async {
    final db = await database;
    return await db.delete('bills', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
