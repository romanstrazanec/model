import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'column.dart';
import 'model.dart';

abstract class DBProvider with ChangeNotifier {
  static Database _db;

  String get databaseName;

  int get databaseVersion;

  Map<String, List<Column>> get tables;

  Future<T> Function<T>(Future<T> Function(Transaction), {bool exclusive})
      get transaction => _db.transaction;

  Batch get batch => _db.batch();

  /// Opens a database. Returns 0 for [FutureBuilder] to catch data.
  Future<int> open() async {
    final dbPath = await getDatabasesPath();
    _db ??= await openDatabase(
      // Open only if _db null.
      join(dbPath, databaseName, '.db'),
      version: databaseVersion,
      onCreate: (db, _) async {
        await db.execute('PRAGMA foreign_keys = ON');
        tables.forEach((name, cols) => _createTable(db, name, cols));
      },
      onUpgrade: _onVersionChange,
      onDowngrade: _onVersionChange,
    );
    assert(_db != null);
    return 0;
  }

  void _onVersionChange(Database db, int oldVersion, int newVersion) {
    tables.forEach((name, cols) {
      _dropTable(db, name);
      _createTable(db, name, cols);
    });
  }

  static Future<void> save(Model model) async {
    if (model.id == null) {
      model.id = await _db.transaction(
        (txn) => txn.insert(
          model.tableName,
          model.toMapForDB(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        ),
      );
    } else {
      // model.id != null means it is already in database.
      _db.transaction(
        (txn) => txn.update(
          model.tableName,
          model.toMapForDB(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        ),
      );
    }
  }

  static Future<void> delete(Model model) async {
    if (model.id != null) {
      await _db.transaction(
        (txn) => txn.delete(
          model.tableName,
          where: '${MetaModel.id} = ?',
          whereArgs: [model.id],
        ),
      );
      model.id = null;
    }
  }

  void queryTables() async {
    for (final table in tables.keys) await queryTable(table);
  }

  static Future<void> queryTable(String table) async {
    print('\n${table.toUpperCase()}:');
    (await _db.transaction((txn) => txn.query(table))).forEach((e) => print(e));
  }

  /// Executes SQL query to create table with [table] in [db] database.
  /// [Columns] must not contain [MetaModel.id] key.
  static void _createTable(
      Database db, String table, List<Column> columns) async {
    String sql = 'CREATE TABLE $table (${MetaModel.id} INTEGER PRIMARY KEY';

    columns.forEach((column) {
      sql +=
          ', ${column.name} ${column.type.toString().split('.').last.toUpperCase()}';
      column.constraints.forEach((constraint) {
        sql += ' $constraint';
      });
    });

    db.execute('$sql);').catchError((_) {});
  }

  static void _dropTable(Database db, String table) async {
    db.execute('DROP TABLE $table;').catchError((_) {});
  }

  static String columnIn(String column, List vals) =>
      '$column IN (${vals.map((_) => '?').join(', ')})';
}
