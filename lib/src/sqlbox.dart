class TypeLen {
  final int _ctype;
  final int _length;

  TypeLen(this._ctype, [this._length = 1]) {
    assert(_ctype != null);
    assert((_length != null) && (_length > 0));
  }

  factory TypeLen.clone(TypeLen object) {
    assert(object != null);

    return new TypeLen(object._ctype, object._length);
  }

  int get ctype => _ctype;
  int get length => _length;
}

abstract class SqlBox<T> extends TypeLen {
  late T value;

  SqlBox(int ctype, [int length = 1]) : super(ctype, length);

  String toString() => value.toString();
}