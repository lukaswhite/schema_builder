import 'package:schema_builder/schema_builder.dart';
import 'package:schema_builder/src/errors/errors.dart';
import 'package:schema_builder/src/expression.dart';
import 'package:schema_builder/src/field.dart';
import 'package:schema_builder/src/table.dart';
import 'package:test/test.dart';

void main() {
  group('Creating tables', () {
    
    setUp(() {
      // Additional setup goes here.
    });

    test('Can create a table', () {
      Builder builder = Builder();
      Table table = builder.table('departments');
      expect(table.name, 'departments');
    });

  });
  group('Adding fields', () {
    test('Cannot create the same table twice', () {
      Builder builder = Builder();
      builder.table('departments');
      expect(() => builder.table('departments'), throwsA(TypeMatcher<DuplicateTable>()));
    });
    test('Can add integer fields', () {
      Builder builder = Builder();
      Table table = builder.table('departments');
      table.integer('id');
      expect(table.fields, isA<List>());
      expect(table.fields.length, 1);
      expect(table.fields.first, isA<Field>());
      expect(table.fields.first.type, FieldType.integer);
      expect(table.fields.first.name, 'id');      
      expect(table.fields.first.isNumeric, true);
      expect(table.fields.first.isNullable, true);
      expect(table.fields.first.isNotNullable, false);
      expect(table.fields.first.isPrimaryKey, false);
      expect(table.fields.first.hasDefault, false);
    });
    test('Can add text fields', () {
      Builder builder = Builder();
      Table table = builder.table('departments');
      table.text('name');
      expect(table.fields, isA<List>());
      expect(table.fields.length, 1);
      expect(table.fields.first, isA<Field>());
      expect(table.fields.first.type, FieldType.text);
      expect(table.fields.first.name, 'name');      
      expect(table.fields.first.isNumeric, false);
      expect(table.fields.first.isNullable, true);
      expect(table.fields.first.isNotNullable, false);
      expect(table.fields.first.isPrimaryKey, false);
      expect(table.fields.first.hasDefault, false);
    });
    test('Can add real fields', () {
      Builder builder = Builder();
      Table table = builder.table('locations');
      table.real('lat');
      expect(table.fields, isA<List>());
      expect(table.fields.length, 1);
      expect(table.fields.first, isA<Field>());
      expect(table.fields.first.type, FieldType.real);
      expect(table.fields.first.name, 'lat');      
      expect(table.fields.first.isNumeric, true);
      expect(table.fields.first.isNullable, true);
      expect(table.fields.first.isNotNullable, false);
      expect(table.fields.first.isPrimaryKey, false);
      expect(table.fields.first.hasDefault, false);
    });
    test('Can add blob fields', () {
      Builder builder = Builder();
      Table table = builder.table('users');
      table.blob('photo');
      expect(table.fields, isA<List>());
      expect(table.fields.length, 1);
      expect(table.fields.first, isA<Field>());
      expect(table.fields.first.type, FieldType.blob);
      expect(table.fields.first.name, 'photo');      
      expect(table.fields.first.isNumeric, false);
      expect(table.fields.first.isNullable, true);
      expect(table.fields.first.isNotNullable, false);
      expect(table.fields.first.isPrimaryKey, false);
      expect(table.fields.first.hasDefault, false);
    });
    test('Cannot add the same field twice', () {
      Builder builder = Builder();
      Table table = builder.table('departments');
      table.integer('id');
      expect(() => table.text('id'), throwsA(TypeMatcher<DuplicateField>()));
    });
  });
  group('Defining fields', () {
    test('Can make a field not null', () {
      Builder builder = Builder();
      Table table = builder.table('departments');
      table.text('email').notNull();
      expect(table.fields.first.isNullable, false);
      expect(
        builder.sql.first,
        'CREATE TABLE departments (\n'
            '\temail TEXT NOT NULL\n'
            ');'
      );
    });
    test('Can default to an integer', () {
      Builder builder = Builder();
      Table table = builder.table('departments');
      table.integer('level').defaultsTo(1);
      expect(table.fields.first.definition, 'level INTEGER DEFAULT 1');
    });
    test('Can default to a double', () {
      Builder builder = Builder();
      Table table = builder.table('departments');
      table.real('score').defaultsTo(1.5);
      expect(table.fields.first.definition, 'score REAL DEFAULT 1.5');
    });
    test('Can default to a string', () {
      Builder builder = Builder();
      Table table = builder.table('departments');
      table.text('name').defaultsTo('John Doe');
      expect(table.fields.first.definition, 'name TEXT DEFAULT "John Doe"');
    });
    test('Can default to the current time', () {
      Builder builder = Builder();
      Table table = builder.table('departments');
      table.text('created_at').defaultsToCurrentTime();
      expect(table.fields.first.definition, 'created_at TEXT DEFAULT CURRENT_TIME');
    });
    test('Can default to the current date', () {
      Builder builder = Builder();
      Table table = builder.table('departments');
      table.text('created_at').defaultsToCurrentDate();
      expect(table.fields.first.definition, 'created_at TEXT DEFAULT CURRENT_DATE');
    });
    test('Can default to the current time', () {
      Builder builder = Builder();
      Table table = builder.table('departments');
      table.text('created_at').defaultsToCurrentTimestamp();
      expect(table.fields.first.definition, 'created_at TEXT DEFAULT CURRENT_TIMESTAMP');
    });
    test('Can default to an expression', () {
      Builder builder = Builder();
      Table table = builder.table('departments');
      table.text('created_at').defaultsTo(Expression('datetime("now")'));
      expect(table.fields.first.definition, 'created_at TEXT DEFAULT (datetime("now"))');
    });
  });
  group('Adding checks', () {
    test('Can specfify expression', () {
      Builder builder = Builder();
      Table table = builder.table('users')..integer('age').check('age < 120');
      expect(table.fields.first.definition, 'age INTEGER CHECK(age < 120)');
    });
    test('Can limit to numeric values', () {
      Builder builder = Builder();
      Table table = builder.table('entries')..integer('level').restrictTo([10, 20, 30]);
      expect(table.fields.first.definition, 'level INTEGER CHECK(level IN (10, 20, 30))');
    });
    test('Can limit to string values', () {
      Builder builder = Builder();
      Table table = builder.table('entries')..text('level').restrictTo(["warn", "debug", "info"]);
      expect(table.fields.first.definition, 'level TEXT CHECK(level IN ("warn", "debug", "info"))');
    });
  });
}
