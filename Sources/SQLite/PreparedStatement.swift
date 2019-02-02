import CSQLite
import class Foundation.NSError

final class PreparedStatement {
  enum StepResult {
    case row
    case done
  }

  private var handle: OpaquePointer?
  unowned let database: Database
  private let userInfo: [String: Any]

  init(sql: String, database: Database) throws {
    self.userInfo = database.userInfo
    let status = sqlite3_prepare_v2(database.handle, sql, -1, &handle, nil)
    guard status == SQLITE_OK else {
      throw NSError(domain: SQLiteError.errorDomain, code: Int(status), userInfo: userInfo)
    }
    self.database = database
  }

  var columnCount: Int {
    return Int(sqlite3_column_count(handle))
  }

  func columnName(at index: Int) -> String {
    guard let name = sqlite3_column_name(handle, Int32(index)) else {
      // A NULL return value indicates that sqlite_malloc() failed,
      // in which case the following string allocation probablywill also,
      // so just bail out here.
      let error = database.error.map { ": \($0)" } ?? ""
      fatalError("Unexpected failure accessing column name\(error)")
    }

    return String(cString: name)
  }

  func columnType(at index: Int) -> SQLiteType {
    return SQLiteType(rawValue: sqlite3_column_type(handle, Int32(index)))!
  }

  func step() throws -> StepResult {
    guard let statement = handle else { return .done }

    switch sqlite3_step(statement) {
    case SQLITE_DONE:
      return .done
    case SQLITE_ROW:
      return .row
    case let error:
      throw NSError(domain: SQLiteError.errorDomain, code: Int(error), userInfo: userInfo)
    }
  }

  func finalize() throws {
    let status = sqlite3_finalize(handle)
    handle = nil
    guard status == SQLITE_OK else {
      throw NSError(domain: SQLiteError.errorDomain, code: Int(status), userInfo: userInfo)
    }
  }

  deinit {
    try? finalize()
  }
}

extension PreparedStatement {
  func get(_: Int32.Type, at index: Int) -> Int32 {
    return sqlite3_column_int(handle, Int32(index))
  }

  func get(_: String.Type, at index: Int) -> String? {
    return sqlite3_column_text(handle, Int32(index)).map(String.init(cString:))
  }
}
