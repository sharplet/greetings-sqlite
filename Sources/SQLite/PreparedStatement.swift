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

  convenience init(statement: SQLTemplate, database: Database) throws {
    try self.init(sql: statement.rawValue, database: database)
    for binding in statement.bindings {
      try binding(self)
    }
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

  func run() throws {
    while case .row = try step() {
      continue
    }
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

  func reset(clearBindings: Bool = false) throws {
    var status: Int32

    status = sqlite3_reset(handle)
    guard status == SQLITE_OK else {
      throw NSError(domain: SQLiteError.errorDomain, code: Int(status), userInfo: userInfo)
    }

    guard clearBindings else { return }
    status = sqlite3_clear_bindings(handle)
    guard status == SQLITE_OK else {
      throw NSError(domain: SQLiteError.errorDomain, code: Int(status), userInfo: userInfo)
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
  func bind(_ value: Bool, at index: Int) throws {
    guard let handle = handle else { return }
    let status = sqlite3_bind_int(handle, Int32(index), value ? 1 : 0)
    guard status == SQLITE_OK else {
      throw NSError(domain: SQLiteError.errorDomain, code: Int(status), userInfo: userInfo)
    }
  }

  func bind(_ value: Int64, at index: Int) throws {
    guard let handle = handle else { return }
    let status = sqlite3_bind_int64(handle, Int32(index), value)
    guard status == SQLITE_OK else {
      throw NSError(domain: SQLiteError.errorDomain, code: Int(status), userInfo: userInfo)
    }
  }

  func bind(_ value: String, at index: Int) throws {
    guard let handle = handle else { return }

    let status = value.utf8CString.withUnsafeBufferPointer { value -> Int32 in
      let encoding = UInt8(SQLITE_UTF8)
      let index = Int32(index)
      let length = sqlite3_uint64(value.count) - 1
      assert(value[Int(length)] == 0)
      return sqlite3_bind_text64(handle, index, value.baseAddress, length, SQLITE_TRANSIENT, encoding)
    }

    guard status == SQLITE_OK else {
      throw NSError(domain: SQLiteError.errorDomain, code: Int(status), userInfo: userInfo)
    }
  }
}

extension PreparedStatement {
  private func columnIndex(forBindParameterName name: String) throws -> Int {
    var index: Int32 = 0

    for prefix in ":@$" where index == 0 {
      let name = "\(prefix)\(name)"
      index = sqlite3_bind_parameter_index(handle, name)
    }

    guard index != 0 else {
      var userInfo = self.userInfo
      userInfo[SQLiteError.bindParameterNameErrorKey] = name
      throw NSError(domain: SQLiteError.errorDomain, code: Int(SQLITE_RANGE), userInfo: userInfo)
    }

    return Int(index)
  }

  func bind(_ value: Bool, forKey key: String) throws {
    let index = try columnIndex(forBindParameterName: key)
    try bind(value, at: index)
  }

  func bind(_ value: String, forKey key: String) throws {
    let index = try columnIndex(forBindParameterName: key)
    try bind(value, at: index)
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
