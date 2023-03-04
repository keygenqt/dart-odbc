Dart ODBC
---

A simple connector for ODBC.
I did not repeat the interface ODBC.

I added the necessary functions in a modest way.

```dart
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