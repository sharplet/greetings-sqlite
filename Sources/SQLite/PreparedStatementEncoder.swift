struct PreparedStatementEncoder: Encoder {
  let codingPath: [CodingKey]
  let singleValueKey: CodingKey?
  let userInfo: [CodingUserInfoKey: Any] = [:]
  private unowned let statement: PreparedStatement

  init(statement: PreparedStatement, codingPath: [CodingKey] = [], singleValueKey: CodingKey? = nil) {
    self.codingPath = codingPath
    self.singleValueKey = singleValueKey
    self.statement = statement
  }

  func container<Key>(keyedBy _: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
    let container = KeyedStatementEncoder<Key>(codingPath: codingPath, statement: statement)
    return KeyedEncodingContainer(container)
  }

  func unkeyedContainer() -> UnkeyedEncodingContainer {
    fatalError()
  }

  func singleValueContainer() -> SingleValueEncodingContainer {
    return SingleValueStatementEncoder(codingPath: codingPath, statement: statement, key: singleValueKey)
  }
}

private struct KeyedStatementEncoder<Key: CodingKey>: KeyedEncodingContainerProtocol {
  let codingPath: [CodingKey]
  private unowned let statement: PreparedStatement

  init(codingPath: [CodingKey], statement: PreparedStatement) {
    self.codingPath = codingPath
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
    let encoder = PreparedStatementEncoder(statement: statement, codingPath: codingPath + [key], singleValueKey: key)
    try value.encode(to: encoder)
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

  mutating func superEncoder(forKey _: Key) -> Encoder {
    fatalError()
  }
}

private struct SingleValueStatementEncoder: SingleValueEncodingContainer {
  let codingPath: [CodingKey]
  let key: CodingKey?
  unowned let statement: PreparedStatement
  private var valueCount = 0

  init(codingPath: [CodingKey], statement: PreparedStatement, key: CodingKey?) {
    self.codingPath = codingPath
    self.statement = statement
    self.key = key
  }

  private mutating func getIndex(for value: Any) throws -> Int {
    valueCount += 1
    guard valueCount == 1 else {
      let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Tried to encode multiple values in a single value container.")
      throw EncodingError.invalidValue(value, context)
    }

    let parameterCount = statement.bindParameterCount
    if codingPath.isEmpty, parameterCount != 1 {
      let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Unable to encode single value with bind parameter count of \(parameterCount).")
      throw EncodingError.invalidValue(value, context)
    }

    return valueCount
  }

  mutating func encodeNil() throws {
    fatalError()
  }

  mutating func encode(_ value: Bool) throws {
    if let key = key {
      try statement.bind(value, forKey: key.stringValue)
    } else {
      let index = try getIndex(for: value)
      try statement.bind(value, at: index)
    }
  }

  mutating func encode(_ value: String) throws {
    if let key = key {
      try statement.bind(value, forKey: key.stringValue)
    } else {
      let index = try getIndex(for: value)
      try statement.bind(value, at: index)
    }
  }

  mutating func encode(_ value: Double) throws {
    fatalError()
  }

  mutating func encode(_ value: Float) throws {
    fatalError()
  }

  mutating func encode(_ value: Int) throws {
    fatalError()
  }

  mutating func encode(_ value: Int8) throws {
    fatalError()
  }

  mutating func encode(_ value: Int16) throws {
    fatalError()
  }

  mutating func encode(_ value: Int32) throws {
    fatalError()
  }

  mutating func encode(_ value: Int64) throws {
    let index = try getIndex(for: value)
    try statement.bind(value, at: index)
  }

  mutating func encode(_ value: UInt) throws {
    fatalError()
  }

  mutating func encode(_ value: UInt8) throws {
    fatalError()
  }

  mutating func encode(_ value: UInt16) throws {
    fatalError()
  }

  mutating func encode(_ value: UInt32) throws {
    fatalError()
  }

  mutating func encode(_ value: UInt64) throws {
    fatalError()
  }

  mutating func encode<T: Encodable>(_ value: T) throws {
    fatalError()
  }
}
