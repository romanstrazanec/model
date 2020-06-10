import 'package:model/model.dart';

class Author extends Model {
  static const table = 'author';
  static const nameCol = 'name';

  @override
  String get tableName => table;

  String name;

  Author({this.name});

  @override
  Map<String, dynamic> toMapForDB() => {nameCol: name};
}
