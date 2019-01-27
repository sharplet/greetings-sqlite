import CSQLite

public struct RowEnumerator<Row: Decodable> {
  let statement: PreparedStatement

  public mutating func next() throws -> Row? {
    return try statement.decodeNext(Row.self)
  }
}
