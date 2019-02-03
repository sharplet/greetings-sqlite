import CSQLite
import class Foundation.NSError

struct SQLiteDecoder: Decoder {
  let codingPath: [CodingKey] = []
  let userInfo: [CodingUserInfoKey: Any] = [:]
  private unowned let statement: PreparedStatement

  init(statement: PreparedStatement) {
    self.statement = statement
  }

  func container<Key>(keyedBy _: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
    let container = KeyedRowDecoder<Key>(statement: statement)
    return KeyedDecodingContainer(container)
  }

  func unkeyedContainer() throws -> UnkeyedDecodingContainer {
    fatalError()
  }

  func singleValueContainer() throws -> SingleValueDecodingContainer {
    fatalError()
  }
}

private struct KeyedRowDecoder<Key: CodingKey>: KeyedDecodingContainerProtocol {
  private let keys: [String: (index: Int, key: Key)]
  private unowned let statement: PreparedStatement

  var allKeys: [Key] {
    return keys.keys.compactMap(Key.init(stringValue:))
  }

  let codingPath: [CodingKey] = []

  init(statement: PreparedStatement) {
    var keys: [String: (Int, Key)] = [:]

    for index in 0 ..< statement.columnCount {
      let name = statement.columnName(at: index)

      if let key = Key(stringValue: name) {
        keys[name] = (index, key)
      }
    }

    self.keys = keys
    self.statement = statement
  }

  private func columnIndex(forKey key: Key) throws -> Int {
    guard let index = keys[key.stringValue]?.index else {
      let context = DecodingError.Context(codingPath: codingPath, debugDescription: "")
      throw DecodingError.keyNotFound(key, context)
    }
    return index
  }

  func contains(_ key: Key) -> Bool {
    return keys[key.stringValue] != nil
  }

  func decodeNil(forKey _: Key) throws -> Bool {
    fatalError()
  }

  func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
    let index = try columnIndex(forKey: key)
    let type = statement.columnType(at: index)
    guard type == .INTEGER else {
      let message = "Expected to decode \(Bool.self) (\(SQLiteType.INTEGER)) but found \(type)"
      throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: message)
    }
    return statement.get(Int32.self, at: index) != 0
  }

  func decode(_ type: String.Type, forKey key: Key) throws -> String {
    let index = try columnIndex(forKey: key)
    let type = statement.columnType(at: index)
    guard type == .TEXT else {
      let message = "Expected to decode \(String.self) (\(SQLiteType.TEXT)) but found \(type)"
      throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: message)
    }
    if let text = statement.get(String.self, at: index) {
      return text
    } else if let error = statement.database.error {
      throw error
    } else {
      let message = "Expected \(String.self) (SQLITE_TEXT) value but found NULL instead."
      let context = DecodingError.Context(codingPath: codingPath + [key], debugDescription: message)
      throw DecodingError.valueNotFound(String.self, context)
    }
  }

  func decode(_: Double.Type, forKey _: Key) throws -> Double {
    fatalError()
  }

  func decode(_: Float.Type, forKey _: Key) throws -> Float {
    fatalError()
  }

  func decode(_: Int.Type, forKey _: Key) throws -> Int {
    fatalError()
  }

  func decode(_: Int8.Type, forKey _: Key) throws -> Int8 {
    fatalError()
  }

  func decode(_: Int16.Type, forKey _: Key) throws -> Int16 {
    fatalError()
  }

  func decode(_: Int32.Type, forKey _: Key) throws -> Int32 {
    fatalError()
  }

  func decode(_: Int64.Type, forKey key: Key) throws -> Int64 {
    let index = try columnIndex(forKey: key)
    let type = statement.columnType(at: index)
    guard type == .INTEGER else {
      let message = "Expected to decode \(Int64.self) (\(SQLiteType.INTEGER)) but found \(type)"
      throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: message)
    }
    return statement.get(Int64.self, at: index)
  }

  func decode(_: UInt.Type, forKey _: Key) throws -> UInt {
    fatalError()
  }

  func decode(_: UInt8.Type, forKey _: Key) throws -> UInt8 {
    fatalError()
  }

  func decode(_: UInt16.Type, forKey _: Key) throws -> UInt16 {
    fatalError()
  }

  func decode(_: UInt32.Type, forKey _: Key) throws -> UInt32 {
    fatalError()
  }

  func decode(_: UInt64.Type, forKey _: Key) throws -> UInt64 {
    fatalError()
  }

  func decode<T>(_: T.Type, forKey _: Key) throws -> T where T: Decodable {
    fatalError()
  }

  func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type, forKey _: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
    fatalError()
  }

  func nestedUnkeyedContainer(forKey _: Key) throws -> UnkeyedDecodingContainer {
    fatalError()
  }

  func superDecoder() throws -> Decoder {
    fatalError()
  }

  func superDecoder(forKey _: Key) throws -> Decoder {
    fatalError()
  }
}
