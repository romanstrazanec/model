import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'column.dart';
import 'model.dart';
import 'db_describer.dart';

/// Provides database.
abstract class DBProvider {
  /// Database.
  static Database _db;

  DatabaseDescriber get describer;

  /// Returns transaction from database.
  static Future<T> Function<T>(
    Future<T> Function(Transaction), {
    bool exclusive,
  }) get transaction => _db.transaction;

  /// Returns database batch.
  static Batch get batch => _db.batch();

  /// Opens a database. Returns future expecting this provider.
  Future<DBProvider> open() async {
    final dbPath = await getDatabasesPath();
    _db ??= await openDatabase(
      // Open only if _db null.
      join(
        dbPath,
        describer.name.endsWith('.db')
            ? describer.name
            : describer.name + '.db',
      ),
      version: describer.version,
      onCreate: (db, _) async {
        await db.execute('PRAGMA foreign_keys = ON');
        describer.tables.forEach((t) => _createTable(db, t.name, t.columns));
      },
      onUpgrade: _onVersionChange,
      onDowngrade: _onVersionChange,
    );
    assert(_db != null);
    return this;
  }

  /// This method runs on database version change.
  void _onVersionChange(Database db, int oldVersion, int newVersion) {
    describer.tables.forEach((t) {
      _dropTable(db, t.name);
      _createTable(db, t.name, t.columns);
    });
  }

  /// Saves the model.
  static Future<void> save(Model model) async {
    if (model.id == null) {
      model.id = await transaction(
        (txn) => txn.insert(
          model.tableName,
          model.toMapForDB(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        ),
      );
    } else {
      // model.id != null means it is already in database.
      transaction(
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
      await transaction(
        (txn) => txn.delete(
          model.tableName,
          where: '${MetaModel.id} = ?',
          whereArgs: [model.id],
        ),
      );
      model.id = null;
    }
  }

  /// Merges model from database.
  static Future<void> merge(Model model) async {
    if (model.id != null) {
      final result = await fetch(model.tableName, id: model.id);
      if (result.isNotEmpty) {
        model.constructFromDB(result.first);
      }
    }
  }

  /// Fetch rows in given [table] either for specific [id] and [ids] or all.
  static Future<List<Map<String, dynamic>>> fetch(
    String table, {
    Set<int> ids,
    int id,
    String where,
    List whereArgs,
  }) async {
    return transaction(
      (txn) {
        if (ids != null) {
          if (id != null) ids.add(id);
          return txn.query(
            table,
            where: columnIn(MetaModel.id, ids),
            whereArgs: ids.toList(growable: false),
            limit: ids.length,
          );
        }

        return id != null
            ? txn.query(
                table,
                where: '${MetaModel.id} = ?',
                whereArgs: <int>[id],
                limit: 1,
              )
            : txn.query(table, where: where, whereArgs: whereArgs);
      },
    );
  }

  /// Print all tables in database.
  void printTables() async {
    for (final table in describer.tables) {
      await printTable(table.name);
    }
  }

  /// Print table in database.
  static Future<void> printTable(String table) async {
    print('\n${table.toUpperCase()}:');
    (await transaction((txn) => txn.query(table))).forEach(print);
  }

  /// Executes SQL query to create table with [table] in [db] database.
  /// [Column]s must not contain [MetaModel.id] key.
  static void _createTable(
    Database db,
    String table,
    Set<Column> columns,
  ) async {
    var sql = 'CREATE TABLE $table (${MetaModel.id} INTEGER PRIMARY KEY';

    for (final column in columns) {
      final type = column.type.toString().split('.').last.toUpperCase();
      sql += ', ${column.name} $type';

      for (final constraint in column.constraints) {
        sql += ' $constraint';
      }
    }

    db.execute('$sql);').catchError(print);
  }

  /// Drops table.
  static void _dropTable(Database db, String table) async {
    db.execute('DROP TABLE $table;').catchError(print);
  }

  /// SQL in operator.
  static String columnIn(String column, Set values) =>
      '$column IN (${values.map((_) => '?').join(', ')})';
}
