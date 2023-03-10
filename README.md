Dart ODBC
---

A simple connector for ODBC. 
The example presented here makes a query to the [ClickHouse](https://clickhouse.com/) database.

With some additions, ["Quick Start"](https://clickhouse.com/docs/en/quick-start#step-3-create-a-database-and-table) example

#### Simple way

```dart
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
```

#### Output

```shell
Success connect
({
  "userId": 101,
  "message": "Hello, ClickHouse!",
  "timestamp": "2023-02-24 18:15:08",
  "metric": -1.0
}, {
  "userId": 101,
  "message": "Granules are the smallest chunks of data read",
  "timestamp": "2023-02-24 18:15:13",
  "metric": 3.14159
}, {
  "userId": 102,
  "message": "Insert a lot of rows per batch",
  "timestamp": "2023-02-23 00:00:00",
  "metric": 1.41421
}, {
  "userId": 102,
  "message": "Sort your data based on your commonly-used queries",
  "timestamp": "2023-02-24 00:00:00",
  "metric": 2.718
})
Success disconnect
```

### Experts way

You can make queries directly to odbc through the interfaces generated by `ffigen`.
Or use the dart `wrapper` if you're missing the `DartODBC` class interface.
Contribution will always be welcome!

### License

```
Copyright 2023 Vitaliy Zarubin

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```