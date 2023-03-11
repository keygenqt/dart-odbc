import 'dart:ffi';

import 'package:dart_odbc/src/sql_handles_odbc.dart';
import 'package:dart_odbc/src/sql_types_odbc.dart';

import 'wrappers_odbc.dart';

export './generated_odbc.dart';

class DartODBC {
  DartODBC({required this.path}) : _lib = NativeLibrary(DynamicLibrary.open(path));

  final String path;
  final NativeLibrary _lib;

  final handleENV = SqlHandleENV();
  final handleDBC = SqlHandleDBC();

  bool connect({
    required String server,
    required String username,
    required String password,
  }) {
    // Allocate environment handle
    int rc = sqlAllocHandle(_lib, SQL_HANDLE_ENV, null, handleENV);

    if (rc == SQL_SUCCESS || rc == SQL_SUCCESS_WITH_INFO) {
      //  Set the ODBC version environment attribute
      rc = sqlSetEnvAttr(_lib, handleENV, SQL_ATTR_ODBC_VERSION, SQL_OV_ODBC3, 0);

      if (rc == SQL_SUCCESS || rc == SQL_SUCCESS_WITH_INFO) {
        // Allocate connection handle
        rc = sqlAllocHandle(_lib, SQL_HANDLE_DBC, handleENV, handleDBC);

        if (rc == SQL_SUCCESS || rc == SQL_SUCCESS_WITH_INFO) {
          // Set login timeout to 5 seconds.
          rc = sqlSetConnectAttr(_lib, handleDBC, SQL_LOGIN_TIMEOUT, 5, 0);

          if (rc == SQL_SUCCESS || rc == SQL_SUCCESS_WITH_INFO) {
            // Connect to data source
            rc = sqlConnect(_lib, handleDBC, server, username, password);

            if (rc == SQL_SUCCESS || rc == SQL_SUCCESS_WITH_INFO) {
              return true;
            } else {
              sqlDisconnect(_lib, handleDBC);
            }
          }
          // Free Handle SQL_HANDLE_DBC
          sqlFreeHandle(_lib, SQL_HANDLE_DBC, handleDBC);
        }
      }
    }
    // Free Handle SQL_HANDLE_ENV
    sqlFreeHandle(_lib, SQL_HANDLE_ENV, handleENV);

    return false;
  }

  bool disconnect() {
    sqlDisconnect(_lib, handleDBC);
    sqlFreeHandle(_lib, SQL_HANDLE_DBC, handleDBC);
    sqlFreeHandle(_lib, SQL_HANDLE_ENV, handleENV);
    return true;
  }

  bool exec(String sql) {
    final handleSTMT = SqlHandleSTMT();

    int rc = sqlAllocHandle(_lib, SQL_HANDLE_STMT, handleDBC, handleSTMT);

    if (rc == SQL_SUCCESS || rc == SQL_SUCCESS_WITH_INFO) {
      rc = sqlExecDirect(_lib, handleSTMT, sql);
      sqlFreeHandle(_lib, SQL_HANDLE_STMT, handleSTMT);
    }

    if (rc == SQL_SUCCESS || rc == SQL_SUCCESS_WITH_INFO || rc == SQL_NO_DATA) {
      return true;
    }

    return false;
  }

  List<Map<String, dynamic>> fetch(
    String sql,
    Map<String, SqlValue> map,
  ) {
    final List<Map<String, dynamic>> response = [];
    final handleSTMT = SqlHandleSTMT();

    int rc = sqlAllocHandle(_lib, SQL_HANDLE_STMT, handleDBC, handleSTMT);

    if (rc == SQL_SUCCESS || rc == SQL_SUCCESS_WITH_INFO) {
      rc = sqlExecDirect(_lib, handleSTMT, sql);

      if (rc != SQL_SUCCESS) {
        sqlFreeHandle(_lib, SQL_HANDLE_STMT, handleSTMT);
        return response;
      }

      while (true) {
        rc = sqlFetch(_lib, handleSTMT);

        if (rc == SQL_SUCCESS || rc == SQL_SUCCESS_WITH_INFO) {
          try {
            int index = 1;
            final Map<String, dynamic> json = {};
            for (var key in map.keys) {
              json[key] = sqlGetData(_lib, handleSTMT, index, map[key]!);
              index++;
            }
            response.add(json);
          } catch (e) {
            print(e.toString());
          }
        } else if (rc == SQL_NO_DATA) {
          break;
        } else {
          print("Fail to fetch data");
          break;
        }
      }
      sqlFreeHandle(_lib, SQL_HANDLE_STMT, handleSTMT);
    }
    return response;
  }
}
