import CSQLite

public struct RowEnumerator<Row: Decodable> {
  private var statement: PreparedStatement?
  private let database: Database

  init(statement: PreparedStatement, database: Database) {
    self.statement = statement
    self.database = database
  }

  public mutating func next() throws -> Row? {
    guard let statement = statement else { return nil }

    switch try statement.step() {
    case .row:
      let decoder = SQLiteDecoder(statement: statement, database: database)
      return try Row(from: decoder)

    case .done:
      try statement.finalize()
      self.statement = nil
      return nil
    }
  }
}
