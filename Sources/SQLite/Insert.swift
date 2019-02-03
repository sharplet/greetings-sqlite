public struct Insert<Table: Insertable, Parameters: Encodable> {
  private let statement: PreparedStatement

  public init(sql: String, in database: Database) throws {
    self.statement = try PreparedStatement(sql: sql, database: database)
  }

  public func bind(_ parameters: Parameters) throws -> Query<Int64> {
    do {
      let encoder = PreparedStatementEncoder(statement: statement)
      try parameters.encode(to: encoder)
      return Query(statement: statement) { statement, state in
        guard state == .done else { return nil }
        return statement.database.lastInsertedRowID!
      }
    } catch {
      try statement.reset()
      throw error
    }
  }
}
