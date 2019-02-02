import CSQLite

public struct SQLTemplate {
  let bindings: [(PreparedStatement) throws -> Void]
  let rawValue: String
}

extension SQLTemplate: ExpressibleByStringInterpolation {
  public init(stringInterpolation: StringInterpolation) {
    self.bindings = stringInterpolation.bindings
    self.rawValue = stringInterpolation.sql
  }

  public init(stringLiteral value: String) {
    self.bindings = []
    self.rawValue = value
  }

  public struct StringInterpolation: StringInterpolationProtocol {
    private var index: Int = 1
    private(set) var bindings: [(PreparedStatement) throws -> Void] = []
    private(set) var sql = ""

    public init(literalCapacity: Int, interpolationCount: Int) {
      bindings.reserveCapacity(interpolationCount)
      sql.reserveCapacity(literalCapacity + interpolationCount)
    }

    private mutating func nextIndex() -> Int {
      defer { index += 1 }
      return index
    }

    public mutating func appendInterpolation(_ value: Bool) {
      let index = nextIndex()
      bindings.append({ try $0.bind(value, at: index) })
      sql += "?"
    }

    public mutating func appendInterpolation(_ value: String) {
      let index = nextIndex()
      bindings.append({ try $0.bind(value, at: index) })
      sql += "?"
    }

    public mutating func appendLiteral(_ literal: String) {
      sql += literal
    }
  }
}
