class Patch {

}

class _RenameTable {
  final String original;
  final String to;

  _RenameTable(this.original, this.to);

  String get sql {
    return '''ALTER TABLE $original
      RENAME TO $to;''';
  }
}