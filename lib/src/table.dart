import 'column.dart';

/// Table.
class Table {
  /// Table name.
  final String name;

  /// Columns.
  final List<Column> columns;

  const Table(this.name, this.columns);
}
