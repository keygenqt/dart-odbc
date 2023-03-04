#include <stdbool.h>
#include <sql.h>

// Connect to odbc
bool connect(char *driver, char *username, char *password);

// Disconect odbc
bool disconnect();

// Query
char *query(char *sql);