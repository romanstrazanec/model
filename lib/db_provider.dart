library model;

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'model.dart';

/// Acts as a singleton. There is [dbProvider] instance to use.
abstract class DBProvider with ChangeNotifier {
  static Database _db;

  /// Database name.
  String get name;

  /// Database version
  int get version;

  /// Tables in database.
  Map<String, List<Column>> get tables;

  Future<T> Function<T>(Future<T> Function(Transaction), {bool exclusive})
      get transaction => _db.transaction;

  Batch get batch => _db.batch();

  /// Opens a database. Returns 0 for [FutureBuilder] to catch data.
  Future<int> open() async {
    final dbPath = await getDatabasesPath();
    _db ??= await openDatabase(
      // Open only if _db null.
      join(dbPath, name, '.db'),
      version: version,
      onCreate: (db, _) async {
        await db.execute('PRAGMA foreign_keys = ON');
        tables.forEach((name, cols) => DBHelper.createTable(db, name, cols));
      },
      onUpgrade: _onVersionChange,
      onDowngrade: _onVersionChange,
    );
    assert(_db != null);
    return 0;
  }

  void _onVersionChange(Database db, int oldVersion, int newVersion) {
    tables.forEach((name, cols) {
      DBHelper.dropTable(db, name);
      DBHelper.createTable(db, name, cols);
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
}

abstract class DBHelper {
  /// Executes SQL query to create table with [table] in [db] database.
  /// [Columns] must not contain [MetaModel.id] key.
  static void createTable(
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

  static void dropTable(Database db, String table) async {
    db.execute('DROP TABLE $table;').catchError((_) {});
  }

  static String columnIn(String column, List vals) =>
      '$column IN (${vals.map((_) => '?').join(', ')})';
}

class Column {
  final String name;
  final SQLiteType type;
  final List<Constraint> constraints;

  const Column(this.name, this.type, this.constraints);
}

abstract class Constraint {
  const Constraint();
}

class Default extends Constraint {
  final value;

  const Default(this.value);

  @override
  String toString() => 'DEFAULT $value';
}

class Unique extends Constraint {
  const Unique();

  @override
  String toString() => 'UNIQUE';
}

class NotNull extends Constraint {
  const NotNull();

  @override
  String toString() => 'NOT NULL';
}

class Check extends Constraint {
  final String condition;

  const Check(this.condition);

  @override
  String toString() => 'CHECK($condition)';
}

class References extends Constraint {
  final String table;

  const References(this.table);

  @override
  String toString() => 'REFERENCES $table(${MetaModel.id})';
}

enum SQLiteType { integer, real, text, blob }
