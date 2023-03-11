import 'package:dart_odbc/dart_odbc.dart';
import 'package:dart_odbc/src/sql_types_odbc.dart';
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

    // delete db if exist
    odbc.exec("DROP DATABASE IF EXISTS helloworld");

    // delete table if exist
    odbc.exec("DROP TABLE IF EXISTS helloworld.my_first_table");

    // create db
    odbc.exec("CREATE DATABASE IF NOT EXISTS helloworld");

    // create table
    odbc.exec("""
CREATE TABLE IF NOT EXISTS helloworld.my_first_table
(
    user_id UInt32,
    message String,
    timestamp DateTime,
    metric Float32
)
ENGINE = MergeTree()
PRIMARY KEY (user_id, timestamp)
    """);

    // insert data
    odbc.exec("""
INSERT INTO helloworld.my_first_table (user_id, message, timestamp, metric) VALUES
    (100, 'My first message',                                   now(),       -1.0    ),
    (101, 'Hello, ClickHouse!',                                 now(),       -1.0    ),
    (102, 'Insert a lot of rows per batch',                     yesterday(), 1.41421 ),
    (102, 'Sort your data based on your commonly-used queries', today(),     2.718   ),
    (101, 'Granules are the smallest chunks of data read',      now() + 5,   3.14159 )
    """);

    // select data
    final result = odbc.fetch("SELECT * FROM helloworld.my_first_table", {
      'userId': SqlValueInt('user_id'),
      'message': SqlValueString('message', 255),
      'timestamp': SqlValueString('timestamp', 255),
      'metric': SqlValueDouble('metric'),
    });

    // map to model
    final models = result.map((json) => HelloModel.fromJson(json));

    // output
    print(models);

    // clear table
    odbc.exec("TRUNCATE TABLE IF EXISTS helloworld.my_first_table");

    // disconnect
    if (odbc.disconnect()) {
      print('Success disconnect');
    }
  } else {
    print('Error connect');
  }
}
