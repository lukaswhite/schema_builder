import 'package:schema_builder/src/errors/errors.dart';

import 'table.dart';
import 'foreign_key.dart';
import 'expression.dart';

class Field {
  final Table table;
  final String name;
  final FieldType type;
  bool _nullable = false;
  bool _isPrimaryKey = false;
  bool _autoIncrements = false;
  bool _isUnique = false;
  String? _references;
  dynamic _default;
  int? length;
  ForeignKey? _foreignKey;
  String? _check;

  Field(this.table, this.name, this.type);
  Field.text(this.table, this.name): type = FieldType.text;
  Field.integer(this.table, this.name): type = FieldType.integer;
  Field.real(this.table, this.name): type = FieldType.real;
  Field.blob(this.table, this.name): type = FieldType.blob;

  void nullable() {
    _nullable = false;
  }

  void notNull() {
    _nullable = true;
  }

  void primaryKey() {
    if(table.hasPrimaryKey) {
      throw PrimaryKeyAlreadyDefined();
    }
    _isPrimaryKey = true;
  }

  void autoIncrements() {
    _autoIncrements = true;
  }

  void unique() {
    _isUnique = true;
  }

  void references(String field) {
    _references = field;
  }

  void defaultsTo(dynamic value) {
    _default = value;
  }

  void defaultsToCurrentTime() {
    defaultsTo(DefaultConstant.currentTime);
  }

  void defaultsToCurrentDate() {
    defaultsTo(DefaultConstant.currentDate);
  }

  void defaultsToCurrentTimestamp() {
    defaultsTo(DefaultConstant.currentTimestamp);
  }

  bool get isNumeric {
    return type == FieldType.integer || type == FieldType.real;
  }

  bool get isNullable {
    return !_nullable;
  }

  bool get isNotNullable {
    return !isNullable;
  }

  bool get isPrimaryKey {
    return _isPrimaryKey;
  }

  bool get isAutoIncrementing {
    return _autoIncrements;
  }

  bool get isUnique {
    return _isUnique;
  }

  bool get hasDefault {
    return _default != null;
  }

  String get typeName {
    switch(type) {
      case FieldType.text:
        return 'TEXT';
      case FieldType.real:
        return 'REAL';
      case FieldType.integer:
        return 'INTEGER';
      case FieldType.blob:
        return 'BLOB';      
    }
  }

  ForeignKey foreignKey(String references, List<String> fields) {
    _foreignKey = ForeignKey(
      references: references,
      foreignKeyColumns: [name],
      parentKeyColumns: fields,
    );
    table.addForeignKey(_foreignKey!);
    return _foreignKey!;
  }

  bool get hasForeignKey {
    return _foreignKey != null;
  }

  bool get hasCheck {
    return _check != null;
  }

  void check(String expression) {
    _check = expression;
  }

  void restrictTo(List<dynamic> values) {
    List<dynamic> escaped = values.map((value) => value is String ? '"$value"' : value).toList();
    check('$name IN (${escaped.join(', ')})');
  }

  String getDefaultConstantName(DefaultConstant constant) {
    switch(constant) {
      case DefaultConstant.currentTime:
        return 'CURRENT_TIME';
      case DefaultConstant.currentDate:
        return 'CURRENT_DATE';
      case DefaultConstant.currentTimestamp:
        return 'CURRENT_TIMESTAMP';    
    }
  }

  dynamic get defaultValue {
    if(_default is int || _default is double) {
      return _default;
    }
    if(_default is String) {
      return '"$_default"';
    }
    if(_default is DefaultConstant) {
      return getDefaultConstantName(_default);
    }
    if(_default is Expression) {
      return '(${_default.value})';
    }
  }

  String get definition {
    String definiton = '$name $typeName';
    if(isNotNullable) {
      definiton = '$definiton NOT NULL';
    }
    if(hasDefault) {
      definiton = '$definiton DEFAULT $defaultValue';
    }
    if(isUnique) {
      definiton = '$definiton UNIQUE';
    }
    if(isPrimaryKey) {
      definiton = '$definiton PRIMARY KEY';
    }
    if(hasCheck) {
      definiton = '$definiton CHECK($_check)';
    }
    return definiton;
  }
}

enum FieldType {
  text,
  integer,
  real,
  blob,
}

enum DefaultConstant {
  currentTime,
  currentDate,
  currentTimestamp,
}