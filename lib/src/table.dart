import 'column.dart';

/// Table.
class Table {
  /// Table name.
  final String name;

  /// Columns.
  final Set<Column> columns;

  const Table({this.name, this.columns});

  @override
  bool operator ==(Object other) => other is Table && other.name == name;

  @override
  int get hashCode => name.hashCode;
}
