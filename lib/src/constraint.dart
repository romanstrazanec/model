import 'model.dart';

/// Column constraint.
abstract class Constraint {
  const Constraint();
}

/// Set default value to column.
class Default extends Constraint {
  final value;

  const Default(this.value);

  @override
  String toString() => 'DEFAULT $value';
}

/// Makes column unique.
class Unique extends Constraint {
  const Unique();

  @override
  String toString() => 'UNIQUE';
}

/// Restricts NULL for column.
class NotNull extends Constraint {
  const NotNull();

  @override
  String toString() => 'NOT NULL';
}

/// Adds validation to column.
class Check extends Constraint {
  final String condition;

  const Check(this.condition);

  @override
  String toString() => 'CHECK($condition)';
}

/// Makes column reference another table.
class References extends Constraint {
  final String table;

  const References(this.table);

  @override
  String toString() => 'REFERENCES $table(${MetaModel.id})';
}
