class ForeignKey {  
  final List<String> foreignKeyColumns;
  final List<String> parentKeyColumns;
  final String references;
  ForeignKeyAction? _onUpdate;
  ForeignKeyAction? _onDelete;

  ForeignKey({required this.references, required this.foreignKeyColumns, required this.parentKeyColumns});

  String actionToText(ForeignKeyAction action) {
    switch(action) {
      case ForeignKeyAction.setNull:
        return 'SET NULL';
      case ForeignKeyAction.setDefault:
        return 'SET DEFAULT';
      case ForeignKeyAction.restrict:
        return 'RESTRICT';
      case ForeignKeyAction.noAction:
        return 'NO ACTION';
      case ForeignKeyAction.cascade:
        return 'CASCADE';        
    }
  }

  bool get hasOnUpdate {
    return _onUpdate != null;
  }

  bool get hasOnDelete {
    return _onDelete != null;
  }

  void onUpdate(ForeignKeyAction action) {
    _onUpdate = action;
  }

  void onDelete(ForeignKeyAction action) {
    _onDelete = action;
  }

  void onUpdateSetNull() {
    _onUpdate = ForeignKeyAction.setNull;
  }

  void onUpdateSetDefault() {
    _onUpdate = ForeignKeyAction.setDefault;
  }

  void onUpdateRestrict() {
    _onUpdate = ForeignKeyAction.restrict;
  }

  void onUpdateNoAction() {
    _onUpdate = ForeignKeyAction.noAction;
  }

  void onUpdateCascade() {
    _onUpdate = ForeignKeyAction.cascade;
  }

  void onDeleteSetNull() {
    _onUpdate = ForeignKeyAction.setNull;
  }

  void onDeleteSetDefault() {
    _onUpdate = ForeignKeyAction.setDefault;
  }

  void onDeleteRestrict() {
    _onUpdate = ForeignKeyAction.restrict;
  }

  void onDeleteNoAction() {
    _onUpdate = ForeignKeyAction.noAction;
  }

  void onDeleteCascade() {
    _onUpdate = ForeignKeyAction.cascade;
  }

  String? get onUpdateSql {
    if(!hasOnUpdate) {
      return null;
    }
    return actionToText(_onUpdate!);
  }

  String? get onDeleteSql {
    if(!hasOnDelete) {
      return null;
    }
    return actionToText(_onDelete!);
  }

}

enum ForeignKeyAction {
  setNull,
  setDefault,
  restrict,
  noAction,
  cascade,
}