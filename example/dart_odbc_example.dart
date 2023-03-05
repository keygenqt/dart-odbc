import 'dart:convert';

import 'package:dart_odbc/dart_odbc.dart';
import 'dart:io' show Directory;
import 'package:path/path.dart' as path;

import 'configuration.dart';
import 'helper.dart';

void main() {
  // get main class
  var odbc = DartOdbc(
    path: path.join(Directory.current.path, 'build', 'libdart_odbc.so'),
  );

  // connect
  if (odbc.connect(
    driver: Configuration.driver,
    username: Configuration.username,
    password: Configuration.password,
  )) {
    // select
    List<Map<String, dynamic>> result = odbc.query("SELECT * FROM helloworld.my_first_table");
    // print
    print(jsonPrettyEncode(result));
    // disconnect
    odbc.disconnect();
  } else {
    print("Error connect");
  }
}
