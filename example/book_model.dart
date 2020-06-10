import 'package:model/model.dart';

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
}
