import 'table.dart';

/// Describes the database.
class DatabaseDescriber {
  /// Database name.
  final String name;

  /// Database version. Cannot be negative.
  final int version;

  /// Database tables.
  final Set<Table> tables;

  const DatabaseDescriber(this.name, this.version, this.tables);

  // DatabaseDescriber({this.name, this.version, this.tables}) {
  //   if (name == null || version == null || tables == null)
  //     throw ArgumentError('Database describer fields cannot be null.');
  //   if (version < 0) throw ArgumentError('Version cannot be negative.');
  // }

  @override
  bool operator ==(Object other) =>
      other is DatabaseDescriber &&
      other.name == name &&
      other.version == version;

  @override
  int get hashCode => name.hashCode * version.hashCode;
}
