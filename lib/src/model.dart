import '../model.dart';
import 'db_provider.dart';

/// Holds column names.
abstract class MetaModel {
  static const String id = '_id';
}

/// Model of a row in database.
abstract class Model {
  /// Implement to get table name.
  String get tableName => runtimeType.toString().toLowerCase();

  /// Primary key.
  int _id;

  int get id => _id;

  set id(int id) {
    if (id < 1) throw ArgumentError('Id cannot be less than 1.');
    _id = id;
  }

  Model();

  /// Implement this method to save values in database.
  Map<String, dynamic> toMapForDB();

  void constructFromDB(Map<String, dynamic> row);

  /// Save model.
  Future<void> save() => DBProvider.save(this);

  /// Delete model.
  Future<void> delete() async => DBProvider.delete(this);

  /// Merge model.
  Future<void> merge() async => DBProvider.merge(this);

  @override
  bool operator ==(Object other) => other is Model && (id ?? -1) == other.id;

  @override
  int get hashCode => super.hashCode * (id?.hashCode ?? 1);

  @override
  String toString() => '$tableName:$id';
}
