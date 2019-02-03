struct PreparedStatementEncoder: Encoder {
  let codingPath: [CodingKey] = []
  let userInfo: [CodingUserInfoKey: Any] = [:]
  private unowned let statement: PreparedStatement

  init(statement: PreparedStatement) {
    self.statement = statement
  }

  func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
    let container = KeyedStatementEncoder<Key>(statement: statement)
    return KeyedEncodingContainer(container)
  }

  func unkeyedContainer() -> UnkeyedEncodingContainer {
    fatalError()
  }

  func singleValueContainer() -> SingleValueEncodingContainer {
    fatalError()
  }
}

private struct KeyedStatementEncoder<Key: CodingKey>: KeyedEncodingContainerProtocol {
  let codingPath: [CodingKey] = []
  private unowned let statement: PreparedStatement

  init(statement: PreparedStatement) {
    self.statement = statement
  }

  mutating func encodeNil(forKey key: Key) throws {
    fatalError()
  }

  mutating func encode(_ value: Bool, forKey key: Key) throws {
    try statement.bind(value, forKey: key.stringValue)
  }

  mutating func encode(_ value: String, forKey key: Key) throws {
    try statement.bind(value, forKey: key.stringValue)
  }

  mutating func encode(_ value: Double, forKey key: Key) throws {
    fatalError()
  }

  mutating func encode(_ value: Float, forKey key: Key) throws {
    fatalError()
  }

  mutating func encode(_ value: Int, forKey key: Key) throws {
    fatalError()
  }

  mutating func encode(_ value: Int8, forKey key: Key) throws {
    fatalError()
  }

  mutating func encode(_ value: Int16, forKey key: Key) throws {
    fatalError()
  }

  mutating func encode(_ value: Int32, forKey key: Key) throws {
    fatalError()
  }

  mutating func encode(_ value: Int64, forKey key: Key) throws {
    fatalError()
  }

  mutating func encode(_ value: UInt, forKey key: Key) throws {
    fatalError()
  }

  mutating func encode(_ value: UInt8, forKey key: Key) throws {
    fatalError()
  }

  mutating func encode(_ value: UInt16, forKey key: Key) throws {
    fatalError()
  }

  mutating func encode(_ value: UInt32, forKey key: Key) throws {
    fatalError()
  }

  mutating func encode(_ value: UInt64, forKey key: Key) throws {
    fatalError()
  }

  mutating func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
    fatalError()
  }

  mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
    fatalError()
  }

  mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
    fatalError()
  }

  mutating func superEncoder() -> Encoder {
    fatalError()
  }

  mutating func superEncoder(forKey key: Key) -> Encoder {
    fatalError()
  }
}
