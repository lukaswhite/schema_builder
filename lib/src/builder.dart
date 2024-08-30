import 'package:schema_builder/src/foreign_key.dart';

import 'table.dart';
import 'field.dart';
import 'index.dart';
import 'errors/errors.dart';

class Builder {

  final List<Table> tables = [];

  Table table(String name) {
    if(tableNames.contains(name)) {
      throw DuplicateTable();
    }
    Table table = Table(name);
    tables.add(table);
    return table;
  }

  List<String> get tableNames {
    return tables.map((table) => table.name).toList();
  }

  List<String> get sql {
    List<String> statements = [];
    for(Table table in tables) {
      //String statement = 'CREATE TABLE ${table.name} (';
      List<String> fieldStatements = [];
      for(Field field in table.fields) {
        fieldStatements.add('\n\t${field.definition}');
      }
      for(ForeignKey foreignKey in table.foreignKeys) {
        String foreignKeyStatement = '\n\tFOREIGN KEY (${foreignKey.foreignKeyColumns.join(', ')}) \n\t\tREFERENCES ${foreignKey.references} (${foreignKey.parentKeyColumns.join(', ')})';
        if(foreignKey.hasOnUpdate) {
          foreignKeyStatement = '$foreignKeyStatement \n\t\t\tON UPDATE ${foreignKey.onUpdateSql}';
        }
        if(foreignKey.hasOnDelete) {
          foreignKeyStatement = '$foreignKeyStatement \n\t\t\tON DELETE ${foreignKey.onDeleteSql}';
        }
        fieldStatements.add(foreignKeyStatement);
      }
      String statement = 'CREATE TABLE ${table.name} (${fieldStatements.join(', ')}\n);';
      statements.add(statement);
      for(Index index in table.indexes) {
        String indexDefinition = index.isUnique ? 'UNIQUE INDEX' : 'INDEX';
        String indexStatement = 'CREATE $indexDefinition ${index.name} ON ${table.name} (${index.fields.join(',')});';
        statements.add(indexStatement);
      }
    }
    return statements;
  }
}