## [0.1.3-nullsafety.1] - 2020/11/07

- enable null-safety experimental features

## [0.1.3] - 2020/10/03

- tableName from runtimeType
- model toString

## [0.1.2] - 2020/10/02

- model id setter (cannot be less than 1)
- model hashCode and equals

## [0.1.1] - 2020/09/20

- fetch where

## [0.1.0+2] - 2020/09/19

- *FIX*: default column constraints

## [0.1.0+1] - 2020/09/19

- *FIX*: database file name 

## [0.1.0] - 2020/09/19

- database mapping

## [0.0.5] - 2020/09/19

- fetching by ids

## [0.0.4] - 2020/09/18

- merging models from database

## [0.0.3] - 2020/06/13

- example
- queryTables -> printTables

## [0.0.2] - 2020/06/09.

- New classes:
    - `DBProvider`
    - `Model`
    - `MetaModel`
    - `Table`
    - `Column`
    - `Constraint`
        - `Default`
        - `Unique`
        - `NotNull`
        - `Check`
        - `References`

    + `SQLiteType` enum

- Importing whole package with:

```dart
import 'package:model/model.dart';
```

## [0.0.1] - 2020/05/28.

- Package initialization.
