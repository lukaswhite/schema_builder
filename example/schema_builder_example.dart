import 'package:schema_builder/schema_builder.dart';

void main() {
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

  builder.table('logs')
    ..integer('id').primaryKey()
    ..text('created_at').defaultsToCurrentTimestamp()
    ..text('level').check('level in ("warn", "info", "debug")');  

  print(builder.sql.join('\n\n'));
}
