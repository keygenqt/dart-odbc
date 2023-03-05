#ifndef _GNU_SOURCE
#define _GNU_SOURCE 1
#endif

#include "dart_odbc.h"
#include <stdbool.h>
#include <string.h>
#include <sql.h>
#include <sqlext.h>
#include <stdio.h>
#include <stdlib.h>

SQLHENV henv = NULL;
SQLHDBC hdbc = NULL;

bool connect(char *driver, char *username, char *password)
{
    SQLRETURN rc;

    hdbc = NULL;
    henv = NULL;

    // Allocate environment handle
    rc = SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, &henv);
    if (rc == SQL_SUCCESS || rc == SQL_SUCCESS_WITH_INFO)
    {
        //  Set the ODBC version environment attribute
        rc = SQLSetEnvAttr(henv, SQL_ATTR_ODBC_VERSION, (void *)SQL_OV_ODBC3, 0);

        if (rc == SQL_SUCCESS || rc == SQL_SUCCESS_WITH_INFO)
        {
            // Allocate connection handle
            rc = SQLAllocHandle(SQL_HANDLE_DBC, henv, &hdbc);

            if (rc == SQL_SUCCESS || rc == SQL_SUCCESS_WITH_INFO)
            {
                // Set login timeout to 5 seconds.
                SQLSetConnectAttr(hdbc, SQL_LOGIN_TIMEOUT, (SQLPOINTER)5, 0);

                // Connect to data source
                rc = SQLConnect(hdbc, (SQLCHAR *)driver, SQL_NTS, (SQLCHAR *)username, SQL_NTS, (SQLCHAR *)password, SQL_NTS);

                if (rc == SQL_SUCCESS || rc == SQL_SUCCESS_WITH_INFO)
                {
                    return true;
                }
                SQLDisconnect(hdbc);
            }
            SQLFreeHandle(SQL_HANDLE_DBC, hdbc);
        }
    }

    SQLFreeHandle(SQL_HANDLE_ENV, henv);

    hdbc = NULL;
    henv = NULL;

    return false;
}

bool disconnect()
{
    if (hdbc)
    {
        SQLDisconnect(hdbc);
        SQLFreeHandle(SQL_HANDLE_DBC, hdbc);
    }

    if (henv)
    {
        SQLFreeHandle(SQL_HANDLE_ENV, henv);
    }
    
    hdbc = NULL;
    henv = NULL;

    return true;
}

SQLHSTMT query(char *sql) {
    SQLRETURN r;
    SQLHSTMT hstmt;

    if (hdbc == NULL || henv == NULL)
    {
        return 0;
    }

    r = SQLAllocHandle(SQL_HANDLE_STMT, hdbc, &hstmt);

    if (!(r == SQL_SUCCESS || r == SQL_SUCCESS_WITH_INFO))
    {
        return 0;
    }
        

    r = SQLExecDirect(hstmt, (SQLCHAR *) sql, SQL_NTS);

    return hstmt;
}

// char *query(char *sql) {
//     SQLRETURN r;
//     SQLHSTMT hstmt;
//     SQLLEN n;

//     SQLINTEGER id;
//     SQLCHAR message[250];

//     if (hdbc == NULL || henv == NULL)
//         return 0;

//     r = SQLAllocHandle(SQL_HANDLE_STMT, hdbc, &hstmt);
//     if (!(r == SQL_SUCCESS || r == SQL_SUCCESS_WITH_INFO))
//         return 0;

//     r = SQLExecDirect(hstmt, (SQLCHAR *) sql, SQL_NTS);

//     char * result = "";

//     while (1)
//     {
//         r = SQLFetch(hstmt);

//         if (r == SQL_SUCCESS || r == SQL_SUCCESS_WITH_INFO)
//         {
//             r = SQLGetData(hstmt, 1, SQL_C_ULONG, &id, 0, &n);
//             r = SQLGetData(hstmt, 2, SQL_C_CHAR, message, 250, &n);
                        
//             char * str;
//             asprintf(&str, "%d, %s\n", id, message);

//             size_t sizeA = strlen(result);
//             size_t sizeB = strlen(str);
//             size_t size = sizeof(char) * (sizeA + sizeB + 1);
                                                            
//             char* c = malloc(size);
//             memcpy(c, result, sizeA);
//             memcpy(c + sizeA, str, sizeB);
//             c[sizeA + sizeB] = '\0';       
//             result = c;
//         }
//         else if (SQL_NO_DATA == r)
//         {
//             break;
//         }
//         else
//         {
//             break;
//         }
//     }

//     SQLFreeHandle(SQL_HANDLE_STMT, hstmt);

//     return result;
// }