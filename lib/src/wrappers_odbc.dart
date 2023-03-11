import 'dart:ffi';

import 'package:dart_odbc/src/sql_handles_odbc.dart';
import 'package:dart_odbc/src/sql_types_odbc.dart';
import "package:ffi/ffi.dart";

export './generated_odbc.dart';

int sqlAllocHandle(
  NativeLibrary lib,
  int handleType,
  SqlHandle? inputHandle,
  SqlHandle? outputHandle,
) =>
    lib.SQLAllocHandle(
      handleType,
      inputHandle == null ? Pointer.fromAddress(SQL_NULL_HANDLE) : inputHandle.handle.cast<SQLHANDLE>().value,
      outputHandle == null ? Pointer.fromAddress(SQL_NULL_HANDLE) : outputHandle.handle,
    );

int sqlSetEnvAttr(
  NativeLibrary lib,
  SqlHandleENV environmentHandle,
  int attribute,
  int value,
  int stringLength,
) =>
    lib.SQLSetEnvAttr(
      environmentHandle.handle.cast<SQLHENV>().value,
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
      connectionHandle.handle.cast<SQLHDBC>().value,
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
      connectionHandle.handle.cast<SQLHDBC>().value,
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
      connectionHandle.handle.cast<SQLHDBC>().value,
    );

int sqlFreeHandle(
  NativeLibrary lib,
  int handleType,
  SqlHandle handle,
) {
  final rc = lib.SQLFreeHandle(
    handleType,
    handle.handle.cast<SQLHDBC>().value,
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
      statementHandle.handle.cast<SQLHSTMT>().value,
      statementText.toNativeUtf8().cast<SQLCHAR>(),
      SQL_NTS,
    );

int sqlFetch(
  NativeLibrary lib,
  SqlHandleSTMT statementHandle,
) =>
    lib.SQLFetch(
      statementHandle.handle.cast<SQLHSTMT>().value,
    );

dynamic sqlGetData(
  NativeLibrary lib,
  SqlHandleSTMT statementHandle,
  int columnNumber,
  SqlValue target,
) {
  Pointer<SQLLEN> n = calloc();
  final SQLPOINTER pinter = target.pointer as SQLPOINTER;

  int rc = lib.SQLGetData(
    statementHandle.handle.cast<SQLHSTMT>().value,
    columnNumber,
    target.type,
    pinter,
    target.length,
    n,
  );

  final result = target.getValue(pinter);

  calloc.free(pinter);
  calloc.free(n);

  if (rc == SQL_SUCCESS || rc == SQL_SUCCESS_WITH_INFO) {
    return result;
  } else {
    throw Exception('Error get data. Code: $rc');
  }
}
