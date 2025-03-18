import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

// Database table and column names
const String tableIncomes = 'incomes';
const String tableGoals = 'goals';
const String tableTransactions = 'transactions';
const String tableInvestments = 'investments';
const String columnId = 'id';
const String columnAmount = 'amount';

// Singleton class to manage the database
class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static const _databaseName = "transactionsDB.db";
  static const _databaseVersion = 10;
  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableIncomes (
        $columnId INTEGER PRIMARY KEY,
        $columnAmount REAL NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableGoals (
        $columnId INTEGER PRIMARY KEY,
        $columnAmount REAL NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableTransactions (
        $columnId INTEGER PRIMARY KEY,
        $columnAmount REAL NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableInvestments (
        $columnId INTEGER PRIMARY KEY,
        $columnAmount REAL NOT NULL
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  Future<double?> getIncome() async {
    final db = await database;
    List<Map<String, dynamic>> result = await db!.query(tableIncomes);
    if (result.isNotEmpty) return result.first[columnAmount] as double;
    return null;
  }

  Future<double?> getGoal() async {
    final db = await database;
    List<Map<String, dynamic>> result = await db!.query(tableGoals);
    if (result.isNotEmpty) return result.first[columnAmount] as double;
    return null;
  }

  Future<double> calculateTotalExpenseAmount() async {
    final db = await database;
    List<Map<String, dynamic>> result = await db!.query(tableTransactions);
    return result.fold(
        0.0, (sum, item) => sum + (item[columnAmount] as double));
  }

  Future<double> calculateTotalInvestmentAmount() async {
    final db = await database;
    List<Map<String, dynamic>> result = await db!.query(tableInvestments);
    return result.fold(
        0.0, (sum, item) => sum + (item[columnAmount] as double));
  }
}
