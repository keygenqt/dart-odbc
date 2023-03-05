import 'dart:ffi' as ffi;
import 'dart:ffi';

import "package:ffi/ffi.dart";

import 'generated_odbc.dart';

class DartOdbc {
  NativeLibrary? _dylib;

  final String path;

  bool get isAwesome => true;

  DartOdbc({required this.path}) {
    _dylib = NativeLibrary(ffi.DynamicLibrary.open(path));
  }

  bool connect({
    required String driver,
    required String username,
    required String password,
  }) {
    return _dylib!.connect(
      driver.toNativeUtf8().cast<Char>(),
      username.toNativeUtf8().cast<Char>(),
      password.toNativeUtf8().cast<Char>(),
    );
  }

  bool disconnect() {
    return _dylib!.disconnect();
  }

  List<Map<String, dynamic>> query(String sql) {
    List<Map<String, dynamic>> result = [];

    Pointer<SQLLEN> n = calloc();
    Pointer<SQLINTEGER> id = calloc();
    Pointer<SQLCHAR> message = calloc();

    final hstmt = _dylib!.query(sql.toNativeUtf8().cast<Char>());

    while (true) {
      var r = _dylib!.SQLFetch(hstmt);
      if (r == SQL_SUCCESS || r == SQL_SUCCESS_WITH_INFO) {
        r = _dylib!.SQLGetData(hstmt, 1, SQL_C_ULONG, id as SQLPOINTER, 0, n);
        r = _dylib!.SQLGetData(hstmt, 2, SQL_C_CHAR, message as SQLPOINTER, 250, n);

        result.add({'userId': id.cast<Int8>().value, 'message': message.cast<Utf8>().toDartString()});

        calloc.free(id);
        calloc.free(message);
      } else {
        break;
      }
    }

    return result;
  }
}
