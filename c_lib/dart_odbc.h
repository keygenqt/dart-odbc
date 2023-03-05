#include <stdbool.h>
#include <sql.h>
#include <sqlext.h>

// Connect to odbc
bool connect(char *driver, char *username, char *password);

// Disconect odbc
bool disconnect();

// Query
SQLHSTMT query(char *sql);