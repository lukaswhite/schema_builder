import 'field.dart';
import 'foreign_key.dart';
import 'index.dart';
import 'errors/errors.dart';

class Table {
  final String name;
  final List<Field> fields = [];
  final List<String> _primaryKey = [];
  final List<ForeignKey> foreignKeys = [];
  final List<Index> indexes = [];

  Table(this.name);

  Field addField(FieldType type, String name) {
    if(fieldNames.contains(name)) {
      throw DuplicateField();
    }
    Field field = Field(this, name, type);
    fields.add(field);
    return field;
  }

  Field text(String name) {
    return addField(FieldType.text, name);
  }

  Field integer(String name) {
    return addField(FieldType.integer, name);
  }

  Field real(String name) {
    return addField(FieldType.real, name);
  }

  Field blob(String name) {
    return addField(FieldType.blob, name);
  }

  List<String> get fieldNames {
    return fields.map((field) => field.name).toList();
  } 

  bool get hasPrimaryKey {
    return _primaryKey.isNotEmpty;
  }

  void addForeignKey(ForeignKey key) {    
    foreignKeys.add(key);
  }

  void addIndex({
    String? field, 
    List<String>? fields, 
    String? name,
    bool unique = false,
  }) {    
    indexes.add(Index(table: this, field: field, fields: fields, name: name, unique: unique,));
  }
}