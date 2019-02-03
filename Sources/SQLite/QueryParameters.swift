public protocol QueryParameters: Encodable {
  associatedtype Table: Insertable where Table.Parameters == Self
  static var bindings: Bindings<Table> { get }
}

extension QueryParameters {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: Table.Columns.self)

    for binding in Self.bindings._bindings {
      try binding.encode(from: self, to: &container)
    }
  }
}
