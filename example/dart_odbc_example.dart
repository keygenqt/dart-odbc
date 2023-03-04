import 'package:dart_odbc/dart_odbc.dart';

import 'configuration.dart';

void main() {

  var awesome = Awesome(
    driver: Configuration.driver,
    username: Configuration.username,
    password: Configuration.password,
  );

  print(awesome.select());
}
