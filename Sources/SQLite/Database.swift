import CSQLite
import class Foundation.NSError
import let Foundation.NSLocalizedDescriptionKey

public final class Database {
  private var handle: OpaquePointer!

  public init(createIfNecessaryAtPath path: String) throws {
    let flags = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE
    let status = sqlite3_open_v2(path, &handle, flags, nil)
    guard status == SQLITE_OK else {
      throw NSError(domain: SQLiteError.errorDomain, code: Int(status))
    }
  }

  public func execute(_ sql: String) throws {
    var error: UnsafeMutablePointer<CChar>?
    let status = sqlite3_exec(handle, sql, nil, nil, &error)

    guard status == SQLITE_OK else {
      let userInfo = error.map { error in
        [NSLocalizedDescriptionKey: String(cString: error)]
      }

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
          let userInfo = error.map { error in
            [NSLocalizedDescriptionKey: String(cString: error)]
          }

          throw NSError(domain: SQLiteError.errorDomain, code: Int(status), userInfo: userInfo)
        }
      }
    }
  }

  deinit {
    let result = sqlite3_close(handle)
    assert(result == SQLITE_OK)
  }
}
