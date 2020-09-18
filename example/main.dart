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
  void constructFromDB(Map<String, dynamic> row) {
    name = row[nameCol] as String;
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
  void constructFromDB(Map<String, dynamic> row) {
    title = row[titleCol] as String;
    description = row[descriptionCol] as String;
    price = row[priceCol] as double;
    numberOfPages = row[numberOfPagesCol] as int;
    authorId = row[authorIdCol] as int;
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
  // Open the database.
  final dbProvider = await MyDBProvider().open();

  // Create and save new author.
  final author = Author(name: 'foo');
  await author.save();

  final mergedAuthor = Author()..id = author.id..merge();
  print('Merged author: ${mergedAuthor.name}');
  print('Author: ${author.name}');
  print('Author are same: ${mergedAuthor.name == author.name}');

  // Create and save new book.
  final book = Book(
    title: 'bar',
    description: 'foo bar',
    price: 10.0,
    authorId: author.id,
  );
  await book.save();

  // Print tables.
  dbProvider.printTables();

  // Remove book from the database.
  book.delete();

  // Book should no longer exist.
  dbProvider.printTables();
}
