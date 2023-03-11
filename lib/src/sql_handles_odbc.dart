import 'dart:ffi';

import 'package:dart_odbc/dart_odbc.dart';
import "package:ffi/ffi.dart";

export './generated_odbc.dart';

abstract class SqlHandle {
  late Pointer<SQLHANDLE> handle;

  void free();
}

class SqlHandleENV extends SqlHandle {
  @override
  final Pointer<SQLHENV> handle = calloc();

  @override
  void free() {
    calloc.free(handle);
  }
}

class SqlHandleDBC extends SqlHandle {
  @override
  final Pointer<SQLHDBC> handle = calloc();

  @override
  void free() {
    calloc.free(handle);
  }
}

class SqlHandleSTMT extends SqlHandle {
  @override
  final Pointer<SQLHSTMT> handle = calloc();

  @override
  void free() {
    calloc.free(handle);
  }
}
