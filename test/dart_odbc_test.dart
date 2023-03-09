import 'package:dart_odbc/dart_odbc.dart';
import 'package:test/test.dart';

import '../example/configuration.dart';

void main() {
  group('A group of tests', () {
    final odbc = DartODBC(
      path: '/lib/x86_64-linux-gnu/libodbc.so',
    );
    test('First Test', () {
      expect(
          odbc.connect(
            server: Configuration.server,
            username: Configuration.username,
            password: Configuration.password,
          ),
          isTrue);
    });
  });
}
