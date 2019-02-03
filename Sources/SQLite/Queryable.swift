public protocol Queryable {
  associatedtype CodingKeys: CodingKey
}

public protocol QueryParametersProtocol: Encodable & Queryable {}

public protocol Insertable: Queryable {
  associatedtype Parameters: QueryParametersProtocol where Parameters.CodingKeys == CodingKeys

  static var insert: Insert<Self, Parameters> { get }
}

public protocol Selectable: Decodable & Queryable {
  static var find: Select<Self, Int64> { get }
}

extension Selectable {
  public static func find(byRowID rowid: Int64) throws -> Query<Self> {
    return try find.bind(rowid)
  }
}
