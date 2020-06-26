import 'constraint.dart';
import 'sqlite_type.dart';

class Column {
  final String name;
  final SQLiteType type;
  final List<Constraint> constraints;

  const Column(this.name, this.type, [this.constraints]);
}
