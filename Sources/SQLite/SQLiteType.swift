enum SQLiteType: Int32 {
  case INTEGER = 1
  case FLOAT = 2
  case TEXT = 3
  case BLOB = 4
  case NULL = 5
}

extension SQLiteType: CustomStringConvertible {
  var description: String {
    switch self {
    case .INTEGER:
      return "SQLITE_INTEGER"
    case .FLOAT:
      return "SQLITE_FLOAT"
    case .TEXT:
      return "SQLITE_TEXT"
    case .BLOB:
      return "SQLITE_BLOB"
    case .NULL:
      return "SQLITE_NULL"
    }
  }
}
