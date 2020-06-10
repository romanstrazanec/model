import './author_model.dart';
import './book_model.dart';
import './db_provider.dart';

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
