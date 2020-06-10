import 'package:model/model.dart';

import './author_model.dart';
import './book_model.dart';

class MyDBProvider extends DBProvider {
  @override
  String get databaseName => 'books';

  @override
  int get databaseVersion => 1;

  @override
  Map<String, List<Column>> get tables => {
        Book.table: <Column>[
          Column(Book.titleCol, SQLiteType.text, <Constraint>[
            Unique(),
            NotNull(),
            Default(''),
          ]),
          Column(Book.descriptionCol, SQLiteType.text),
          Column(Book.priceCol, SQLiteType.real),
          Column(Book.numberOfPagesCol, SQLiteType.integer),
          Column(Book.authorIdCol, SQLiteType.integer, <Constraint>[
            References(Author.table),
          ])
        ],
        Author.table: <Column>[
          Column(Author.nameCol, SQLiteType.text, <Constraint>[
            Unique(),
            NotNull(),
          ])
        ],
      };
}
