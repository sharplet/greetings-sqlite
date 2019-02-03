public struct Query<Row> {
  private let getRow: (PreparedStatement, PreparedStatement.StepResult) throws -> Row?
  private let statement: PreparedStatement

  init(statement: PreparedStatement, getRow: @escaping (PreparedStatement, PreparedStatement.StepResult) throws -> Row?) {
    self.getRow = getRow
    self.statement = statement
  }

  func run(rowHandler: ((Row) throws -> Void)?) throws {
    try statement.ensuringReset(clearBindings: true) {
      if let rowHandler = rowHandler {
        var state: PreparedStatement.StepResult
        repeat {
          state = try statement.step()
          if let result = try getRow(statement, state) {
            try rowHandler(result)
          }
        } while state != .done
      } else {
        try statement.run()
      }
    }
  }
}

private extension PreparedStatement {
  func ensuringReset(clearBindings: Bool, _ body: () throws -> Void) throws {
    do {
      try body()
      try reset(clearBindings: clearBindings)
    } catch {
      try reset(clearBindings: clearBindings)
      throw error
    }
  }
}
