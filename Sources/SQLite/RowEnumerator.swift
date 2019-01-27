import CSQLite

public struct RowEnumerator<Row: Decodable> {
  let statement: PreparedStatement

  public mutating func next() throws -> Row? {
    switch try statement.decodeNext(Row.self) {
    case let .row(row):
      return row
    case .done:
      try statement.finalize()
      return nil
    }
  }
}
