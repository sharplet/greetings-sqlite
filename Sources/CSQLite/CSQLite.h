#include <sqlite3.h>

#undef SQLITE_STATIC
#undef SQLITE_TRANSIENT

static const sqlite3_destructor_type _Nonnull SQLITE_STATIC = ((sqlite3_destructor_type)0);
static const sqlite3_destructor_type _Nonnull SQLITE_TRANSIENT = ((sqlite3_destructor_type)-1);
