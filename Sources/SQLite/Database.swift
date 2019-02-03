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

  public var lastInsertedRowID: Int64? {
    let id = sqlite3_last_insert_rowid(handle)
    guard id != 0 else { return nil }
    return id
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

  public func execute<Row>(_ query: Query<Row>, rowHandler: ((Row) throws -> Void)? = nil) throws {
    try query.run(rowHandler: rowHandler)
  }

  public func execute<Row: Decodable>(_ statement: SQLTemplate, as _: Row.Type) throws -> RowEnumerator<Row> {
    let statement = try PreparedStatement(statement: statement, database: self)
    return RowEnumerator(statement: statement)
  }

  public func execute(_ statement: SQLTemplate) throws {
    let statement = try PreparedStatement(statement: statement, database: self)
    while case .row = try statement.step() {
      continue
    }
  }

  public func execute(_ sql: String, rowHandler: (Row) throws -> Void) throws {
    try withoutActuallyEscaping(rowHandler) { rowHandler in
      let context = RowContext(handler: rowHandler)
      let status = sqlite3_exec(handle, sql, context.callback, context.pointer, nil)
      guard status == SQLITE_OK else {
        throw context.error ?? NSError(domain: SQLiteError.errorDomain, code: Int(status), userInfo: userInfo)
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

  var userInfo: [String: Any] {
    return [NSFilePathErrorKey: path]
  }
}
