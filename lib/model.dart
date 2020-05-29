library model;

import 'db_provider.dart';

abstract class MetaModel {
  static const id = 'id';
}

abstract class Model {
  int id;

  String get tableName;

  Model();

  /// Must be implemented by subclass.
  Model.fromDB(Map<String, dynamic> map) : id = map[MetaModel.id];

  Map<String, dynamic> toMapForDB();

  Future<void> save() {
    return DBProvider.save(this);
  }

  Future<void> delete() async {
    DBProvider.delete(this);
  }
}
