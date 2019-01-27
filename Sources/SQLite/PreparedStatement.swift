import CSQLite
import class Foundation.NSError

final class PreparedStatement {
  private var statement: OpaquePointer?

  init(connection: OpaquePointer, sql: String) throws {
    let status = sqlite3_prepare_v2(connection, sql, -1, &statement, nil)
    guard status == SQLITE_OK else {
      throw NSError(domain: SQLiteError.errorDomain, code: Int(status))
    }
  }

  func decodeNext<Row: Decodable>(_: Row.Type) throws -> Row? {
    guard let statement = statement else { return nil }

    switch sqlite3_step(statement) {
    case SQLITE_DONE:
      try finalize()
      return nil
    case SQLITE_ROW:
      break
    case let error:
      throw NSError(domain: SQLiteError.errorDomain, code: Int(error))
    }

    let decoder = SQLiteDecoder(statement: statement)
    return try Row(from: decoder)
  }

  func finalize() throws {
    let status = sqlite3_finalize(statement)
    statement = nil
    guard status == SQLITE_OK else {
      throw NSError(domain: SQLiteError.errorDomain, code: Int(status))
    }
  }

  deinit {
    try? finalize()
  }
}
