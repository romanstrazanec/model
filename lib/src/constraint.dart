import 'model.dart';

/// Column constraint.
abstract class Constraint {
  const Constraint();

  String get sql;

  @override
  String toString() => sql;
}

/// Set default value to column.
class Default extends Constraint {
  final value;

  const Default(this.value);

  @override
  String get sql => 'DEFAULT $value';
}

/// Makes column unique.
class Unique extends Constraint {
  const Unique();

  @override
  String get sql => 'UNIQUE';
}

/// Restricts NULL for column.
class NotNull extends Constraint {
  const NotNull();

  @override
  String get sql => 'NOT NULL';
}

/// Adds validation to column.
class Check extends Constraint {
  final String condition;

  const Check(this.condition);

  @override
  String get sql => 'CHECK($condition)';
}

/// Makes column reference another table.
class References extends Constraint {
  final String table;

  const References(this.table);

  @override
  String get sql => 'REFERENCES $table(${MetaModel.id})';
}
