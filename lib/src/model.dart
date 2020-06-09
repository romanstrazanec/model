import 'db_provider.dart';

/// Holds column names.
abstract class MetaModel {
  static const String id = '_id';
}

/// Model of a row in database.
abstract class Model {
  /// Implement to get table name.
  String get tableName;

  /// Primary key.
  int id;

  Model();

  /// Implement this method to save values in database.
  Map<String, dynamic> toMapForDB();

  /// Save model.
  Future<void> save() {
    return DBProvider.save(this);
  }

  /// Delete model.
  Future<void> delete() async {
    DBProvider.delete(this);
  }
}
