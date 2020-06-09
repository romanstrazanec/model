import 'constraint.dart';
import 'sqlite_type.dart';

/// Column of database.
class Column {
  /// Column name.
  final String name;

  /// Column type.
  final SQLiteType type;

  /// Additional constraints.
  final List<Constraint> constraints;

  const Column(this.name, this.type, [this.constraints]);
}
