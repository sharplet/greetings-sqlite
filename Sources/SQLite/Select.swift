public struct Select<Row: Selectable, Parameters> {
  private let statement: PreparedStatement

  public init(sql: String, in database: Database) throws {
    self.statement = try PreparedStatement(sql: sql, database: database)
  }
}

extension Select where Parameters: Encodable {
  public func bind(_ parameters: Parameters) throws -> Query<Row> {
    do {
      let encoder = PreparedStatementEncoder(statement: statement)
      try parameters.encode(to: encoder)
      return makeQuery()
    } catch {
      try statement.reset()
      throw error
    }
  }
}

extension Select where Parameters == Void {
  public func bind() -> Query<Row> {
    return makeQuery()
  }
}

private extension Select {
  func makeQuery() -> Query<Row> {
    return Query(statement: statement) { statement, state in
      guard state == .row else { return nil }
      let decoder = SQLiteDecoder(statement: statement)
      return try Row(from: decoder)
    }
  }
}
