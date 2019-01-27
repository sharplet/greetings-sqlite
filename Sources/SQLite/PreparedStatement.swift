import CSQLite
import class Foundation.NSError

final class PreparedStatement {
  enum StepResult {
    case row
    case done
  }

  private(set) var handle: OpaquePointer?
  private unowned let database: Database

  init(sql: String, database: Database) throws {
    let status = sqlite3_prepare_v2(database.handle, sql, -1, &handle, nil)
    guard status == SQLITE_OK else {
      throw NSError(domain: SQLiteError.errorDomain, code: Int(status))
    }
    self.database = database
  }

  func step() throws -> StepResult {
    guard let statement = handle else { return .done }

    switch sqlite3_step(statement) {
    case SQLITE_DONE:
      return .done
    case SQLITE_ROW:
      return .row
    case let error:
      throw NSError(domain: SQLiteError.errorDomain, code: Int(error))
    }
  }

  func finalize() throws {
    let status = sqlite3_finalize(handle)
    handle = nil
    guard status == SQLITE_OK else {
      throw NSError(domain: SQLiteError.errorDomain, code: Int(status))
    }
  }

  deinit {
    try? finalize()
  }
}
