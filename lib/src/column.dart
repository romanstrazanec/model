import 'constraint.dart';
import 'sqlite_type.dart';

/// Column of database.
class Column {
  /// Column name.
  final String name;

  /// Column type.
  final SQLiteType type;

  /// Additional constraints.
  final Set<Constraint> constraints;

  const Column(this.name, this.type, [this.constraints = const <Constraint>{}]);

  @override
  bool operator ==(Object other) => other is Column && other.name == name;

  @override
  int get hashCode => name.hashCode;
}
