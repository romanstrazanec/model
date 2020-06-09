import 'db_provider.dart';

abstract class MetaModel {
  static const String id = '_id';
}

abstract class Model {
  String get tableName;

  int id;

  Model();

  Map<String, dynamic> toMapForDB();

  Future<void> save() {
    return DBProvider.save(this);
  }

  Future<void> delete() async {
    DBProvider.delete(this);
  }
}
