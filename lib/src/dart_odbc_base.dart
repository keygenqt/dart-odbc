import 'dart:ffi' as ffi;
import 'dart:ffi';
import 'dart:io' show Directory;

import "package:ffi/ffi.dart";
import 'package:path/path.dart' as path;

typedef Select = Pointer<Utf8> Function();

class Awesome {
  bool get isAwesome => true;

  final String driver;
  final String username;
  final String password;

  DynamicLibrary? _dylib;

  Awesome({
    required this.driver,
    required this.username,
    required this.password,
  }) {
    var libraryPath = path.join(Directory.current.path, 'c_lib', 'build', 'libdart_odbc.so');
    _dylib = ffi.DynamicLibrary.open(libraryPath);
  }

  String select() {
    final select = _dylib!.lookupFunction<Select, Select>('select');
    return select().toDartString();
  }
}
