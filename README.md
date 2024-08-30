
# Schema Builder

A tiny Dart library for building SQL schemas programmatically.

```dart
Builder.table('users')
    ..integer('id').primaryKey()
    ..text('forename').notNull()
    ..text('surname').notNull()
    ..blob('photo')
    ..text('email').unique();
```

## Motivation

Do you have code that looks like this?

```dart
await database.execute('''CREATE TABLE departments (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL
);''');
await database.execute('CREATE INDEX idx_name ON departments (name);');
await database.execute('''CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    forename TEXT NOT NULL,
    surname TEXT NOT NULL,
    email TEXT UNIQUE,
    department_id INTEGER,
    FOREIGN KEY (department_id)
        REFERENCES departments (id)
            ON UPDATE CASCADE
);''');
await database.execute('''CREATE TABLE departments (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL
);''');
```

Build those `CREATE` statements programmatically instead:

```dart
Builder builder = Builder();

builder.table('departments')
    ..integer('id').primaryKey()
    ..text('name').notNull()
    ..addIndex(field: 'name');

builder.table('employees')
    ..integer('id').primaryKey()
    ..text('forename').notNull()
    ..text('surname').notNull()
    ..text('email').unique()
    ..integer('department_id')
      .foreignKey('departments', ['id'])
      .onUpdateCascade()
    ..addIndex(field: 'surname');

// builder.sql is a list of SQL statements

```

## Usage

Start by creating a builder, then add tables:

```dart
Builder builder = Builder();

builder.table('users')
```

Once you have a reference to a table, start adding fields:

```dart
var table = builder.table('users');
table.text('name');
table.integer('age');
table.real('score');
table.blob('photo');
```

These all return a reference to the field, so you can add various modifiers:

```dart
table..integer('id').primaryKey();
table..text('name').notNull().unique();
```

## Field Defaults

You can specify defaults for a field:

```dart
table..integer('score').defaultsTo(0);
table..text('name').defaultsTo('John Doe');
```

If you're defaulting to an expression, you need to do this:

```dart
table.text('created_at').defaultsTo(Expression('datetime("now")'));
```

For dates and times, you can alternatively do this:

```dart
table.text('created_at').defaultsToCurrentTime();
// or
table.text('created_at').defaultsToCurrentDate();
// or
table.text('created_at').defaultsToCurrentTimestamp();
```

> This uses the constants `CURRENT_TIME`, `CURRENT_DATE` or `CURRENT_TIMESTAMP`.

## Adding checks

You can add a check to a field:

```dart
builder.table('users')..integer('age').check('age <= 120');
```

For enum-type fields, you can use the `restrictTo()` method:

```dart
builder.table('entries')..text('level').restrictTo(["warn", "debug", "info"]);
```

## Indexes

You can specify that a field must be unique when creating it, but for non-unique indexes you'd add those to the table definition.

```dart
table.addIndex(field: 'surname');
```

To create an index for multiple fields, do this instead:

```dart
table.addIndex(fields: ['surname', 'forename']);
```

To make it unique:

```dart
table.addIndex(
    fields: ['department_id', 'user_id'],
    unique: true,    
);
```

This will generate a name for you (e.g. `idx_users_surname`), but you can provide your own:

```dart
table.addIndex(
    field: 'surname',
    name: 'my-surname-index',
);
```

## Foreign Keys

There are two ways to create a foreign key; when creating a field, or by adding it to the table. The former is generally likely to be the best approach:

```dart
table..integer('department_id')
    .foreignKey('departments', ['id'])
```

Once you have a reference to a foreign key, you can define actions:

```dart
onUpdateSetNull()
onUpdateSetDefault()
onUpdateRestrict()
onUpdateNoAction()
onUpdateCascade()

onDeleteSetNull()
onDeleteSetDefault()
onDeleteRestrict()
onDeleteNoAction()
onDeleteCascade()
```

## SQL

Ultimately, the builder's job is to generate SQL statements. You can get these via the `sql` getter.

If you're using sqflite (note, you don't have to and it's not a dependency):

```dart
import 'package:sqflite/sqflite.dart' as sql;

class DatabaseHelper {
  static Future<void> createTables(sql.Database database) async {
    Builder builder = Builder();
    sql.Batch = database.batch();
    for(statement in builder) {
        batch.execute(statement);
    }
    await batch.commit();
  }
}