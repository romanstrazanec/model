abstract class Constraint {
  const Constraint();
}

class Default extends Constraint {
  final value;

  const Default(this.value);

  @override
  String toString() => 'DEFAULT $value';
}

class Unique extends Constraint {
  const Unique();

  @override
  String toString() => 'UNIQUE';
}

class NotNull extends Constraint {
  const NotNull();

  @override
  String toString() => 'NOT NULL';
}

class Check extends Constraint {
  final String condition;

  const Check(this.condition);

  @override
  String toString() => 'CHECK($condition)';
}

class References extends Constraint {
  final String table;
  final String primaryColumn;

  const References(this.table, this.primaryColumn);

  @override
  String toString() => 'REFERENCES $table($primaryColumn)';
}
