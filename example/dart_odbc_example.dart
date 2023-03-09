import 'dart:io' show Directory;

import 'package:dart_odbc/dart_odbc.dart';
import 'package:dart_odbc/src/wrappers_odbc.dart';
import 'package:path/path.dart' as path;

import 'configuration.dart';
import 'models/hello.dart';

void main() {
  final odbc = DartODBC(
    path: path.join('/lib/x86_64-linux-gnu/libodbc.so'),
  );

  if (odbc.connect(
    server: Configuration.server,
    username: Configuration.username,
    password: Configuration.password,
  )) {
    print('Success connect');

    final result = odbc.query("SELECT * FROM helloworld.my_first_table", {
      'userId': SqlValueInt(),
      'message': SqlValueString(255),
      'timestamp': SqlValueString(255),
      'metric': SqlValueDouble(),
    });

    final models = result.map((json) => HelloModel.fromJson(json));

    print(models);

    if (odbc.disconnect()) {
      print('Success disconnect');
    }
  } else {
    print('Error connect');
  }
}
