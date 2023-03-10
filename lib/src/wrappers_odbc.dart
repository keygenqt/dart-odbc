import 'dart:ffi';

import 'package:dart_odbc/dart_odbc.dart';
import "package:ffi/ffi.dart";

export './generated_odbc.dart';

abstract class SqlValue {
  late Pointer<dynamic> _value;
  late int _type;
  late int _length;

  dynamic getValue();

  void free();
}

class SqlValueInt extends SqlValue {
  @override
  final Pointer<SQLINTEGER> _value = calloc();
  final int _type = SQL_C_ULONG;
  final int _length = 0;

  @override
  dynamic getValue() {
    return _value.cast<Int>().value;
  }

  @override
  void free() {
    calloc.free(_value);
  }
}

class SqlValueDouble extends SqlValue {
  @override
  final Pointer<Float> _value = calloc();
  final int _type = SQL_C_FLOAT;
  final int _length = 0;

  @override
  dynamic getValue() {
    return _value.cast<Float>().value.toDouble();
  }

  @override
  void free() {
    // ===== CRASH ===== ?
    // calloc.free(_value);
  }
}

class SqlValueString extends SqlValue {
  SqlValueString(this._length) : _value = calloc(_length);

  final int _length;

  final Pointer<SQLCHAR> _value;
  final int _type = SQL_C_CHAR;

  @override
  dynamic getValue() {
    return _value.cast<Utf8>().toDartString();
  }

  @override
  void free() {
    calloc.free(_value);
  }
}

abstract class SqlHandle {
  late Pointer<SQLHANDLE> _handle;

  void free();
}

class SqlHandleENV extends SqlHandle {
  @override
  final Pointer<SQLHENV> _handle = calloc();

  @override
  void free() {
    calloc.free(_handle);
  }
}

class SqlHandleDBC extends SqlHandle {
  @override
  final Pointer<SQLHDBC> _handle = calloc();

  @override
  void free() {
    calloc.free(_handle);
  }
}

class SqlHandleSTMT extends SqlHandle {
  @override
  final Pointer<SQLHSTMT> _handle = calloc();

  @override
  void free() {
    calloc.free(_handle);
  }
}

int sqlAllocHandle(
  NativeLibrary lib,
  int handleType,
  SqlHandle? inputHandle,
  SqlHandle? outputHandle,
) =>
    lib.SQLAllocHandle(
      handleType,
      inputHandle == null ? Pointer.fromAddress(SQL_NULL_HANDLE) : inputHandle._handle.cast<SQLHANDLE>().value,
      outputHandle == null ? Pointer.fromAddress(SQL_NULL_HANDLE) : outputHandle._handle,
    );

int sqlSetEnvAttr(
  NativeLibrary lib,
  SqlHandleENV environmentHandle,
  int attribute,
  int value,
  int stringLength,
) =>
    lib.SQLSetEnvAttr(
      environmentHandle._handle.cast<SQLHENV>().value,
      attribute,
      Pointer.fromAddress(value),
      stringLength,
    );

int sqlSetConnectAttr(
  NativeLibrary lib,
  SqlHandleDBC connectionHandle,
  int attribute,
  int value,
  int stringLength,
) =>
    lib.SQLSetConnectAttr(
      connectionHandle._handle.cast<SQLHDBC>().value,
      attribute,
      Pointer.fromAddress(value),
      stringLength,
    );

int sqlConnect(
  NativeLibrary lib,
  SqlHandleDBC connectionHandle,
  String serverName,
  String userName,
  String authentication,
) =>
    lib.SQLConnect(
      connectionHandle._handle.cast<SQLHDBC>().value,
      serverName.toNativeUtf8().cast<UnsignedChar>(),
      SQL_NTS,
      userName.toNativeUtf8().cast<UnsignedChar>(),
      SQL_NTS,
      authentication.toNativeUtf8().cast<UnsignedChar>(),
      SQL_NTS,
    );

int sqlDisconnect(
  NativeLibrary lib,
  SqlHandleDBC connectionHandle,
) =>
    lib.SQLDisconnect(
      connectionHandle._handle.cast<SQLHDBC>().value,
    );

int sqlFreeHandle(
  NativeLibrary lib,
  int handleType,
  SqlHandle handle,
) {
  final rc = lib.SQLFreeHandle(
    handleType,
    handle._handle.cast<SQLHDBC>().value,
  );
  handle.free();
  return rc;
}

int sqlExecDirect(
  NativeLibrary lib,
  SqlHandleSTMT statementHandle,
  String statementText,
) =>
    lib.SQLExecDirect(
      statementHandle._handle.cast<SQLHSTMT>().value,
      statementText.toNativeUtf8().cast<SQLCHAR>(),
      SQL_NTS,
    );

int sqlFetch(
  NativeLibrary lib,
  SqlHandleSTMT statementHandle,
) =>
    lib.SQLFetch(
      statementHandle._handle.cast<SQLHSTMT>().value,
    );

dynamic sqlGetData(
  NativeLibrary lib,
  SqlHandleSTMT statementHandle,
  int columnNumber,
  SqlValue target,
) {
  Pointer<SQLLEN> n = calloc();

  int rc = lib.SQLGetData(
    statementHandle._handle.cast<SQLHSTMT>().value,
    columnNumber,
    target._type,
    target._value as SQLPOINTER,
    target._length,
    n,
  );

  final result = target.getValue();

  target.free();
  calloc.free(n);

  if (rc == SQL_SUCCESS || rc == SQL_SUCCESS_WITH_INFO) {
    return result;
  } else {
    throw Exception('Error get data. Code: $rc');
  }
}
