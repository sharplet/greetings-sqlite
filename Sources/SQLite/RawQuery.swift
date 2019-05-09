public struct RawQuery<Table: Queryable> {
  public let sql: String

  public init(sql: String) {
    self.sql = sql
  }
}

extension RawQuery: ExpressibleByStringLiteral {
  public init(stringLiteral: String) {
    self.init(sql: stringLiteral)
  }
}

extension RawQuery: ExpressibleByStringInterpolation {
  public struct StringInterpolation: StringInterpolationProtocol {
    var sql: String

    public init(literalCapacity: Int, interpolationCount _: Int) {
      self.sql = ""
      sql.reserveCapacity(literalCapacity)
    }

    public mutating func appendInterpolation(_ columns: Table.Columns.Type) {
      sql += columns.allCases.lazy
        .map { $0.stringValue }
        .joined(separator: ", ")
    }

    public mutating func appendInterpolation(_ column: Table.Columns) {
      sql += column.stringValue
    }

    public mutating func appendLiteral(_ literal: String) {
      sql += literal
    }
  }

  public init(stringInterpolation: StringInterpolation) {
    self.init(sql: stringInterpolation.sql)
  }
}
