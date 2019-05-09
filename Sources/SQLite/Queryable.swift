public typealias Column = CaseIterable & CodingKey

public protocol Queryable {
  associatedtype CodingKeys: Column
}

extension Queryable {
  public typealias Columns = CodingKeys
}

public protocol Insertable: Queryable {
  associatedtype Parameters: QueryParameters

  static var insert: Insert<Self, Parameters> { get }
}

public protocol Selectable: Decodable, Queryable {
  static var find: Select<Self, Int64> { get }
}

extension Selectable {
  public static func find(byRowID rowid: Int64) throws -> Query<Self> {
    return try find.bind(rowid)
  }
}
