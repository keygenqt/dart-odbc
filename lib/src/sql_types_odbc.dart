import 'dart:ffi';

import 'package:dart_odbc/dart_odbc.dart';
import "package:ffi/ffi.dart";

export './generated_odbc.dart';

abstract class SqlValue {
  late Pointer<dynamic> pointer;
  late String name;
  late int type;
  late int length;

  dynamic getValue(Pointer<dynamic> p);
}

class SqlValueInt extends SqlValue {
  SqlValueInt(this.name);
  @override
  Pointer<SQLINTEGER> get pointer => calloc<SQLINTEGER>();
  @override
  final String name;
  @override
  int type = SQL_C_ULONG;
  @override
  final int length = 0;

  @override
  dynamic getValue(Pointer<dynamic> p) {
    return p.cast<Int>().value;
  }
}

class SqlValueDouble extends SqlValue {
  SqlValueDouble(this.name);
  @override
  Pointer<Float> get pointer => calloc<Float>();
  @override
  final String name;
  @override
  final int type = SQL_C_FLOAT;
  @override
  final int length = 0;

  @override
  dynamic getValue(Pointer<dynamic> p) {
    return p.cast<Float>().value.toDouble();
  }
}

class SqlValueString extends SqlValue {
  SqlValueString(this.name, this.length);

  @override
  Pointer<SQLCHAR> get pointer => calloc<SQLCHAR>(length);
  @override
  final String name;
  @override
  final int length;
  @override
  final int type = SQL_C_CHAR;

  @override
  dynamic getValue(Pointer<dynamic> p) {
    return p.cast<Utf8>().toDartString();
  }
}
