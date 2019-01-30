import CSQLite
import class Foundation.NSError
import let Foundation.NSFilePathErrorKey
import let Foundation.NSLocalizedDescriptionKey

public final class Database {
  private(set) var handle: OpaquePointer!
  private let path: String

  public var error: Error? {
    let status = sqlite3_errcode(handle)
    guard status != SQLITE_OK else { return nil }
    return NSError(domain: SQLiteError.errorDomain, code: Int(status))
  }

  public init(createIfNecessaryAtPath path: String) throws {
    var status = sqlite3_open_v2(path, &handle, SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE, nil)
    self.path = path

    guard status == SQLITE_OK else {
      throw NSError(domain: SQLiteError.errorDomain, code: Int(status), userInfo: userInfo)
    }

    status = sqlite3_exec(handle, "PRAGMA schema_version;", nil, nil, nil)

    guard status == SQLITE_OK else {
      // If we can't close a database we just opened, something is really wrong.
      try! close()
      throw NSError(domain: SQLiteError.errorDomain, code: Int(status), userInfo: userInfo)
    }
  }

  deinit {
    do {
      try close()
    } catch {
      assertionFailure("\(error)")
    }
  }

  public func execute<Row: Decodable>(_ sql: String, as _: Row.Type) throws -> RowEnumerator<Row> {
    let statement = try PreparedStatement(sql: sql, database: self)
    return RowEnumerator(statement: statement)
  }

  public func execute(_ sql: String) throws {
    var error: UnsafeMutablePointer<CChar>?
    let status = sqlite3_exec(handle, sql, nil, nil, &error)
    guard status == SQLITE_OK else {
      throw NSError(domain: SQLiteError.errorDomain, code: Int(status), userInfo: userInfo)
    }
  }

  public func execute(_ sql: String, rowHandler: (Row) throws -> Void) throws {
    try withoutActuallyEscaping(rowHandler) { rowHandler in
      let context = RowContext(handler: rowHandler)
      var error: UnsafeMutablePointer<CChar>?

      let status = sqlite3_exec(handle, sql, context.callback, context.pointer, &error)

      guard status == SQLITE_OK else {
        if let error = context.error {
          throw error
        } else {
          var userInfo = self.userInfo

          if let error = error {
            userInfo[NSLocalizedDescriptionKey] = String(cString: error)
          }

          throw NSError(domain: SQLiteError.errorDomain, code: Int(status), userInfo: userInfo)
        }
      }
    }
  }

  private func close() throws {
    let result = sqlite3_close_v2(handle)
    guard result == SQLITE_OK else {
      throw NSError(domain: SQLiteError.errorDomain, code: Int(result), userInfo: userInfo)
    }
    handle = nil
  }

  private var userInfo: [String: Any] {
    return [NSFilePathErrorKey: path]
  }
}
