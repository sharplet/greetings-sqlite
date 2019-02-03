public struct Select<Row: Selectable, Parameters: Encodable> {
  private let statement: PreparedStatement

  public init(sql: String, in database: Database) throws {
    self.statement = try PreparedStatement(sql: sql, database: database)
  }

  public func bind(_ parameters: Parameters) throws -> Query<Row> {
    do {
      let encoder = PreparedStatementEncoder(statement: statement)
      try parameters.encode(to: encoder)
      return Query(statement: statement) { statement, state in
        guard state == .row else { return nil }
        let decoder = SQLiteDecoder(statement: statement)
        return try Row(from: decoder)
      }
    } catch {
      try statement.reset()
      throw error
    }
  }
}
