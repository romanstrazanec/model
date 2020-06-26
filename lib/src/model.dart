import 'db_provider.dart';

abstract class MetaModel {
  static const String id = '_id';
}

abstract class Model {
  int id;

  Model();

  Model.fromDB(Map<String, dynamic> map) {
    buildFromDB(map);
  }

  void buildFromDB(Map<String, dynamic> map);

  Map<String, dynamic> toMapForDB();

  Future<void> save() {
    return DBProvider.save(this);
  }

  Future<void> delete() async {
    DBProvider.delete(this);
  }
}
