import 'package:dart_odbc/dart_odbc.dart';

import 'configuration.dart';

void main() {

  var odbc = DartOdbc();

  if (odbc.connect(
    driver: Configuration.driver,
    username: Configuration.username,
    password: Configuration.password,
  )) {
    // select
    print(odbc.query("SELECT * FROM helloworld.my_first_table"));
    // disconnect
    odbc.disconnect();
  } else {
    print("Error connect");
  }
}
