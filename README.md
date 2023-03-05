Dart ODBC
---

A simple connector for ODBC.
I did not repeat the interface ODBC.

I added the necessary functions in a modest way.

```dart
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
```

#### Output

```shell
[
  {
    "userId": 101,
    "message": "Hello, ClickHouse!"
  },
  {
    "userId": 101,
    "message": "Granules are the smallest chunks of data read"
  },
  {
    "userId": 102,
    "message": "Insert a lot of rows per batch"
  },
  {
    "userId": 102,
    "message": "Sort your data based on your commonly-used queries"
  }
]

```

### License

```
Copyright 2022-2023 Vitaliy Zarubin

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