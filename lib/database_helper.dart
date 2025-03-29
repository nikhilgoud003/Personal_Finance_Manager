import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'transaction.dart' as txn;
import 'investment.dart' as inv;

// database table and column names
final String tableTransactions = 'transactions';
final String columnId = 'id';
final String columnTitle = 'title';
final String columnAmount = 'amount';
final String columnCategory = 'category';
final String columnDate = 'date';

final String tableIncomes = 'incomes';
final String tableGoals = 'goals';
final String tableInvestments = 'investments';

// singleton class to manage the database
class DatabaseHelper {
  // Make this a singleton class.
  DatabaseHelper._privateConstructor();

  // actual database filename that is saved in the docs directory.
  static final _databaseName = "transactionsDB.db";

  // Increment this version when you need to change the schema.
  static final _databaseVersion = 10;

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  static Database? _database = null;

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await _initDatabase();
    return _database;
  }

  // open the database
  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    String path = join(documentsDirectory.path, _databaseName);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future _onUpgrade(Database db, int version, int newVersion) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableInvestments (
        $columnId INTEGER PRIMARY KEY,
        $columnTitle TEXT NOT NULL,
        $columnAmount REAL NOT NULL,
        $columnDate TEXT NOT NULL
      )
    ''');
  }

  // SQL string to create the database
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $tableTransactions (
            $columnId INTEGER PRIMARY KEY,
            $columnTitle TEXT NOT NULL,
            $columnAmount REAL NOT NULL,
            $columnCategory TEXT NOT NULL,
            $columnDate TEXT NOT NULL
          )
          ''');
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
        CREATE TABLE $tableInvestments (
          $columnId INTEGER PRIMARY KEY,
          $columnTitle TEXT NOT NULL,
          $columnAmount REAL NOT NULL,
          $columnDate TEXT NOT NULL
          )
      ''');
    print('Investments table is created');
  }

  // Database helper methods:

  Future<int> insert(txn.Transaction element) async {
    Database? db = await database;
    int id = await db?.insert(tableTransactions, element.toMap()) ?? 0;
    return id;
  }

  Future<txn.Transaction?> getTransactionById(int id) async {
    Database? db = await database;
    if (db != null) {
      List<Map<String, dynamic>> res = await db.query(
        tableTransactions,
        columns: [
          columnId,
          columnTitle,
          columnAmount,
          columnCategory,
          columnDate
        ],
        where: '$columnId = ?',
        whereArgs: [id],
      );

      if (res.isNotEmpty) {
        return txn.Transaction.fromMap(res.first);
      }
    }
    return null;
  }

  Future<List<txn.Transaction>> getAllTransactions() async {
    Database? db = await database;
    List<Map<String, dynamic>> res = [];

    if (db != null) {
      res = await db.query(tableTransactions, columns: [
        columnId,
        columnTitle,
        columnAmount,
        columnCategory,
        columnDate
      ]);
    }

    List<txn.Transaction> list =
        res.map((e) => txn.Transaction.fromMap(e)).toList();
    return list;
  }

  Future<double> calculateTotalExpenseAmount() async {
    Database? db = await database;
    List<Map<String, dynamic>> res = [];

    if (db != null) {
      res = await db.query(tableTransactions, columns: [
        columnId,
        columnTitle,
        columnAmount,
        columnCategory,
        columnDate
      ]);
    }

    List<txn.Transaction> list =
        res.map((e) => txn.Transaction.fromMap(e)).toList();
    // Calculate the sum of columnAmount
    double sum = list.fold(0,
        (previousValue, transaction) => previousValue + transaction.txnAmount);
    return sum;
  }

  Future<int> deleteTransactionById(int id) async {
    Database? db = await database;
    if (db != null) {
      int res = await db.delete(
        tableTransactions,
        where: "id = ?",
        whereArgs: [id],
      );
      return res;
    } else {
      // Handle the case where db is null
      return 0; // Or any other appropriate value indicating failure
    }
  }

  Future<int> deleteAllTransactions() async {
    Database? db = await database;
    if (db != null) {
      int res = await db.delete(tableTransactions, where: '1');
      return res;
    } else {
      // Handle the case where db is null
      return 0; // Or any other appropriate value indicating failure
    }
  }

  // Insert income into incomes table
  Future<int> insertIncome(double amount) async {
    final db = await database;
    return await db!.insert(tableIncomes, {'$columnAmount': amount});
  }

  // Insert goal into goals table
  Future<int> insertGoal(double amount) async {
    final db = await database;
    return await db!.insert(tableGoals, {'$columnAmount': amount});
  }

  // Fetch current income
  Future<double?> getIncome() async {
    final db = await database;
    List<Map<String, dynamic>> result = await db!.query(tableIncomes);
    if (result.isNotEmpty) {
      return result.first[columnAmount] as double;
    } else {
      return null;
    }
  }

  // Fetch current goal
  Future<double?> getGoal() async {
    final db = await database;
    List<Map<String, dynamic>> result = await db!.query(tableGoals);
    if (result.isNotEmpty) {
      return result.first[columnAmount] as double;
    } else {
      return null;
    }
  }

  // Update income
  Future<void> updateIncome(double amount) async {
    final db = await database;
    await db!.update(tableIncomes, {'$columnAmount': amount});
  }

  // Update goal
  Future<void> updateGoal(double amount) async {
    final db = await database;
    await db!.update(tableGoals, {'$columnAmount': amount});
  }

  Future<int> insertInvestment(inv.Investment element) async {
    Database? db = await database;
    int id = await db?.insert(tableInvestments, element.toMap()) ?? 0;
    return id;
  }

  Future<inv.Investment?> getInvestmentById(int id) async {
    Database? db = await database;
    if (db != null) {
      List<Map<String, dynamic>> res = await db.query(
        tableInvestments,
        columns: [columnId, columnTitle, columnAmount, columnDate],
        where: '$columnId = ?',
        whereArgs: [id],
      );

      if (res.isNotEmpty) {
        return inv.Investment.fromMap(res.first);
      }
    }
    return null;
  }

  Future<List<inv.Investment>> getAllInvestments() async {
    Database? db = await database;
    List<Map<String, dynamic>> res = [];

    if (db != null) {
      res = await db.query(tableInvestments,
          columns: [columnId, columnTitle, columnAmount, columnDate]);
    }

    List<inv.Investment> list =
        res.map((e) => inv.Investment.fromMap(e)).toList();
    return list;
  }

  Future<double> calculateTotalInvestmentAmount() async {
    Database? db = await database;
    List<Map<String, dynamic>> res = [];

    if (db != null) {
      res = await db.query(tableInvestments,
          columns: [columnId, columnTitle, columnAmount, columnDate]);
    }

    List<inv.Investment> list =
        res.map((e) => inv.Investment.fromMap(e)).toList();
    // Calculate the sum of columnAmount
    double sum = list.fold(
        0, (previousValue, investment) => previousValue + investment.invAmount);
    return sum;
  }

  Future<int> deleteInvestmentById(int id) async {
    Database? db = await database;
    if (db != null) {
      int res = await db.delete(
        tableInvestments,
        where: "id = ?",
        whereArgs: [id],
      );
      return res;
    } else {
      // Handle the case where db is null
      return 0; // Or any other appropriate value indicating failure
    }
  }

  Future<int> deleteAllInvestments() async {
    Database? db = await database;
    if (db != null) {
      int res = await db.delete(tableInvestments, where: '1');
      return res;
    } else {
      // Handle the case where db is null
      return 0; // Or any other appropriate value indicating failure
    }
  }
}
