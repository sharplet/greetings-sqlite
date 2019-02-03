public struct Insert<Table: Insertable, Parameters: Encodable> {
  private let statement: PreparedStatement

  public init(sql: String, in database: Database) throws {
    statement = try PreparedStatement(sql: sql, database: database)
  }

  public func bind(_ parameters: Parameters) throws -> Query<Int64> {
    do {
      let encoder = PreparedStatementEncoder(statement: statement)
      try parameters.encode(to: encoder)
      return Query(statement: statement, getRow: { $0.database.lastInsertedRowID! })
    } catch {
      try statement.reset()
      throw error
    }
  }
}
