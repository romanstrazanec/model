import 'db_provider.dart';

abstract class MetaModel {
  static const String id = '_id';
}

abstract class Model {
  int id;

  void buildFromDB(Map<String, dynamic> map);

  Map<String, dynamic> toMapForDB();

  Future<void> save() {
    return DBProvider.save(this);
  }

  Future<void> delete() async {
    DBProvider.delete(this);
  }

  Future<Model> fetch([int id]) async {
    DBProvider.fetch(this, id ?? this.id);
  }
}
