class Index {
  late List<String> _fields;
  bool _unique = false;
  String? _name;

  Index({String? field, List<String>? fields, String? name, bool unique = false,}) {
    assert(field != null || fields != null, 'Must specify a single field or multiple fields');
    _fields = fields ?? [field!];
    _name = name;
    _unique = false;
  }
  
  void unique() {
    _unique = true;
  }

  bool get isUnique {
    return _unique;
  }

  String get name {
    if(_name != null) {
      return _name!;
    }
    String name = 'idx_${_fields.join('_')}';
    if(isUnique) {
      name = '${name}_uniq';
    }
    return name;
  }

  List<String> get fields {
    return _fields;
  }

}