infix operator <-

public func <- <Table: Insertable, Value: Encodable>(column: Table.Columns, keyPath: KeyPath<Table.Parameters, Value>) -> Bindings<Table>.Binding {
  return .init { parameters, container in
    let value = parameters[keyPath: keyPath]
    try container.encode(value, forKey: column)
  }
}

public struct Bindings<Table: Insertable>: ExpressibleByArrayLiteral {
  typealias Key = Table.Columns
  typealias Parameters = Table.Parameters

  public struct Binding {
    fileprivate let _encodeValue: (Parameters, inout KeyedEncodingContainer<Key>) throws -> Void

    func encode(from parameters: Parameters, to container: inout KeyedEncodingContainer<Key>) throws {
      try _encodeValue(parameters, &container)
    }
  }

  let _bindings: [Binding]

  public init(arrayLiteral bindings: Binding...) {
    self._bindings = bindings
  }
}
