import 'dart:ffi' as ffi;
import 'dart:ffi';
import 'dart:io' show Directory;
import "package:ffi/ffi.dart";
import 'package:path/path.dart' as path;
import 'generated_odbc.dart';

class DartOdbc {

  NativeLibrary? _dylib;

  bool get isAwesome => true;

  DartOdbc() {
    var libraryPath = path.join(Directory.current.path, 'c_lib', 'build', 'libdart_odbc.so');
    _dylib = NativeLibrary(ffi.DynamicLibrary.open(libraryPath));
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

  String query(String sql) {
    return _dylib!.query(sql.toNativeUtf8().cast<Char>()).cast<Utf8>().toDartString();
  }
}
