import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/portfolio_holding.dart';
import '../models/portfolio_data.dart';

class PortfolioDatabase {
  static final PortfolioDatabase instance = PortfolioDatabase._init();
  static Database? _database;

  PortfolioDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('portfolio.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Holdings table
    await db.execute('''
    CREATE TABLE holdings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      coinId TEXT NOT NULL,
      coinName TEXT NOT NULL,
      coinSymbol TEXT NOT NULL,
      quantity REAL NOT NULL,
      currentPrice REAL NOT NULL
    )
  ''');
    await db.execute('''
    CREATE TABLE portfolio (
      id INTEGER PRIMARY KEY,
      totalValue REAL NOT NULL
    )
    ''');
  }
  Future<void> upsertHolding(PortfolioHolding holding) async {
    final db = await instance.database;
    await db.insert(
      'holdings',
      holding.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeHolding(String coinId) async {
    final db = await instance.database;
    await db.delete(
      'holdings',
      where: 'coinId = ?',
      whereArgs: [coinId],
    );
  }

  Future<List<PortfolioHolding>> getHoldings() async {
    final db = await instance.database;
    final result = await db.query('holdings');
    return result.map((json) => PortfolioHolding.fromJson(json)).toList();
  }

  Future<void> savePortfolio(PortfolioData portfolio) async {
    final db = await instance.database;
    await db.insert(
      'portfolio',
      {'id': 1, 'totalValue': portfolio.totalValue},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<PortfolioData> loadPortfolio() async {
    final db = await instance.database;
    final holdings = await getHoldings();

    final result = await db.query('portfolio', where: 'id = ?', whereArgs: [1]);
    double totalValue = 0.0;
    if (result.isNotEmpty) {
      totalValue = result.first['totalValue'] as double;
    }

    return PortfolioData(holdings: holdings, totalValue: totalValue);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
