import 'package:flutter_test/flutter_test.dart';
import 'package:model/model.dart';

class MyDBProvider extends DBProvider {
  @override
  String get databaseName => 'test';

  @override
  Map<String, List<Column>> get tables => {
        'table1': <Column>[
          Column('column1', SQLiteType.text),
        ],
        'table2': <Column>[
          Column('column2', SQLiteType.real, <Constraint>[
            NotNull(),
            Unique(),
            Default(0.0),
          ]),
        ],
      };

  @override
  int get databaseVersion => 1;
}

void main() {
  test('Test', () {
    // todo test
  });
}
