import 'package:model/model.dart';

// Create models Author and Book by extending Model class.

class Author extends Model {
  static const table = 'author';
  static const nameCol = 'name';

  @override
  String get tableName => table;

  String name;

  Author({this.name});

  @override
  Map<String, dynamic> toMapForDB() => {nameCol: name};

  @override
  void buildFromDB(Map<String, dynamic> map) {
    name = map[nameCol] as String;
  }
}

class Book extends Model {
  static const table = 'book';
  static const titleCol = 'title';
  static const descriptionCol = 'description';
  static const priceCol = 'price';
  static const numberOfPagesCol = 'number_of_pages';
  static const authorIdCol = 'author_id';

  @override
  String get tableName => table;

  String title;
  String description;
  double price;
  int numberOfPages;
  int authorId;

  Book({
    this.title,
    this.description,
    this.price,
    this.numberOfPages,
    this.authorId,
  });

  @override
  Map<String, dynamic> toMapForDB() => {
        titleCol: title,
        descriptionCol: description,
        priceCol: price,
        numberOfPagesCol: numberOfPages,
        authorIdCol: authorId,
      };

  @override
  void buildFromDB(Map<String, dynamic> map) {
    title = map[titleCol] as String;
    description = map[descriptionCol] as String;
    price = map[priceCol] as double;
    numberOfPages = map[numberOfPagesCol] as int;
    authorId = map[authorIdCol] as int;
  }
}

// Extend DBProvider class to provide database.

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

// Main method shows the use of the provider together with the models.

void main() async {
  final dbProvider = await MyDBProvider().open();

  final author = Author(name: 'foo');
  await author.save();

  final book = Book(
    title: 'bar',
    description: 'foo bar',
    price: 10.0,
    authorId: author.id,
  );
  await book.save();

  // Print tables.
  dbProvider.printTables();

  book.delete();

  // Book should no longer exist.
  dbProvider.printTables();
}
