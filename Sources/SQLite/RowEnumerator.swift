import CSQLite

public struct RowEnumerator<Row: Decodable> {
  private var statement: PreparedStatement?

  init(statement: PreparedStatement) {
    self.statement = statement
  }

  public mutating func next() throws -> Row? {
    guard let statement = statement else { return nil }

    switch try statement.step() {
    case .row:
      let decoder = SQLiteDecoder(statement: statement)
      return try Row(from: decoder)

    case .done:
      try statement.finalize()
      self.statement = nil
      return nil
    }
  }
}
