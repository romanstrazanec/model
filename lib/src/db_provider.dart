import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'column.dart';
import 'model.dart';

/// Provides database.
abstract class DBProvider {
  /// Database.
  static Database _db;

  /// Implement this getter to set the database name.
  String get databaseName;

  /// Implement this getter to set the database version.
  int get databaseVersion;

  /// Implement this getter to provide the structure of the database.
  Map<String, List<Column>> get tables;

  /// Returns transaction from database.
  static Future<T> Function<T>(Future<T> Function(Transaction),
      {bool exclusive}) get transaction => _db.transaction;

  /// Returns database batch.
  static Batch get batch => _db.batch();

  /// Opens a database. Returns future expecting this provider.
  Future<DBProvider> open() async {
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
    return this;
  }

  /// This method runs on database version change.
  void _onVersionChange(Database db, int oldVersion, int newVersion) {
    tables.forEach((name, cols) {
      _dropTable(db, name);
      _createTable(db, name, cols);
    });
  }

  /// Saves the model.
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

  /// Deletes model from database.
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

  /// Print all tables in database.
  void printTables() async {
    for (final table in tables.keys) {
      await printTable(table);
    }
  }

  /// Print table in database.
  static Future<void> printTable(String table) async {
    print('\n${table.toUpperCase()}:');
    (await _db.transaction((txn) => txn.query(table))).forEach(print);
  }

  /// Executes SQL query to create table with [table] in [db] database.
  /// [Column]s must not contain [MetaModel.id] key.
  static void _createTable(
    Database db,
    String table,
    List<Column> columns,
  ) async {
    var sql = 'CREATE TABLE $table (${MetaModel.id} INTEGER PRIMARY KEY';

    for (final column in columns) {
      final type = column.type.toString().split('.').last.toUpperCase();
      sql += ', ${column.name} $type';

      for (final constraint in column.constraints) {
        sql += ' $constraint';
      }
    }

    db.execute('$sql);').catchError((_) {});
  }

  /// Drops table.
  static void _dropTable(Database db, String table) async {
    db.execute('DROP TABLE $table;').catchError((_) {});
  }

  /// SQL in operator.
  static String columnIn(String column, List values) =>
      '$column IN (${values.map((_) => '?').join(', ')})';
}
