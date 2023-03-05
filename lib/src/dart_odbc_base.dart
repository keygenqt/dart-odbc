import 'dart:ffi';

import "package:ffi/ffi.dart";

import 'generated_odbc.dart';
import 'model.dart';

class DartOdbc {
  NativeLibrary? _dylib;

  final String path;
  List<Model> models;

  bool get isAwesome => true;

  DartOdbc({
    required this.path,
    this.models = const [],
  }) {
    _dylib = NativeLibrary(DynamicLibrary.open(path));
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

  List<T> query<T extends Model>(String sql) {
    List<T> list = [];

    Pointer<SQLLEN> n = calloc();

    final model = models.firstWhere((element) => element.runtimeType == T);

    final List<Map<String, dynamic>> columns = [];

    final hstmt = _dylib!.query("DESCRIBE TABLE helloworld.my_first_table;".toNativeUtf8().cast<Char>());

    Pointer<SQLCHAR> pName = calloc();
    Pointer<SQLCHAR> pType = calloc();

    while (true) {
      var r = _dylib!.SQLFetch(hstmt);
      if (r == SQL_SUCCESS || r == SQL_SUCCESS_WITH_INFO) {
        r = _dylib!.SQLGetData(hstmt, 1, SQL_C_CHAR, pName as SQLPOINTER, 250, n);
        r = _dylib!.SQLGetData(hstmt, 2, SQL_C_CHAR, pType as SQLPOINTER, 250, n);

        final name = pName.cast<Utf8>().toDartString();
        final type = pType.cast<Utf8>().toDartString();

        columns.add({
          name.replaceAllMapped(RegExp(r'_(\w)'), (m) => '${m[1]}'.toUpperCase()): type,
        });

        calloc.free(pName);
        calloc.free(pType);
      } else {
        break;
      }
    }

    final hstmt2 = _dylib!.query(sql.toNativeUtf8().cast<Char>());

    while (true) {
      var r = _dylib!.SQLFetch(hstmt2);
      if (r == SQL_SUCCESS || r == SQL_SUCCESS_WITH_INFO) {
        final Map<String, dynamic> json = {};
        columns.asMap().forEach((index, element) {
          if (element.values.first == 'UInt32') {
            Pointer<SQLINTEGER> value = calloc();
            r = _dylib!.SQLGetData(hstmt2, index + 1, SQL_C_ULONG, value as SQLPOINTER, 0, n);
            json[element.keys.first] = value.cast<Int8>().value;
            calloc.free(value);
          } else {
            Pointer<SQLCHAR> value = calloc();
            r = _dylib!.SQLGetData(hstmt2, index + 1, SQL_C_CHAR, value as SQLPOINTER, 250, n);
            final result = value.cast<Utf8>().toDartString();
            if (element.values.first == 'Float32') {
              final d = double.parse(result);
              json[element.keys.first] = d;
            } else {
              json[element.keys.first] = result;
            }
            calloc.free(value);
          }
        });
        list.add(model.fromJson(json) as T);
      } else {
        break;
      }
    }
    return list;
  }
}
