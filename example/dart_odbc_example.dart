import 'dart:io' show Directory;

import 'package:dart_odbc/dart_odbc.dart';
import 'package:path/path.dart' as path;

import 'configuration.dart';
import 'hello.dart';
import 'helper.dart';

void main() {
  // get main class
  var odbc = DartOdbc(
    path: path.join(Directory.current.path, 'build', 'libdart_odbc.so'),
    models: [
      HelloModel.empty()
    ]
  );

  // connect
  if (odbc.connect(
    driver: Configuration.driver,
    username: Configuration.username,
    password: Configuration.password,
  )) {
    // select
    List<HelloModel> result = odbc.query<HelloModel>("SELECT * FROM helloworld.my_first_table");
    // print
    print(jsonPrettyEncode(result));
    // disconnect
    odbc.disconnect();
  } else {
    print("Error connect");
  }
}
