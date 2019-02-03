public protocol Queryable {
  associatedtype CodingKeys: CodingKey
}

public protocol QueryParametersProtocol: Encodable & Queryable {}

public protocol Insertable: Queryable {
  associatedtype Parameters: QueryParametersProtocol where Parameters.CodingKeys == CodingKeys
}
