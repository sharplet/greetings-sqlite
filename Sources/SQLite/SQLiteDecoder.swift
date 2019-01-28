import CSQLite
import class Foundation.NSError

struct SQLiteDecoder: Decoder {
  let codingPath: [CodingKey] = []
  let userInfo: [CodingUserInfoKey: Any] = [:]
  private unowned let statement: PreparedStatement

  private var database: Database {
    return statement.database
  }

  init(statement: PreparedStatement) {
    self.statement = statement
  }

  func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
    let container = try KeyedRowDecoder<Key>(statement: statement, database: database)
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
  private let keys: [String: (index: Int32, key: Key)]
  private unowned let statement: PreparedStatement
  private unowned let database: Database

  var allKeys: [Key] {
    return keys.keys.compactMap(Key.init(stringValue:))
  }

  let codingPath: [CodingKey] = []

  init(statement: PreparedStatement, database: Database) throws {
    let count = sqlite3_column_count(statement.handle)
    var keys: [String: (Int32, Key)] = [:]

    for i in 0..<count {
      guard let name = sqlite3_column_name(statement.handle, i).map(String.init(cString:)) else {
        throw database.error!
      }

      if let key = Key(stringValue: name) {
        keys[name] = (i, key)
      }
    }

    self.keys = keys
    self.database = database
    self.statement = statement
  }

  private func columnIndex(forKey key: Key) throws -> Int32 {
    guard let index = keys[key.stringValue]?.index else {
      let context = DecodingError.Context(codingPath: codingPath, debugDescription: "")
      throw DecodingError.keyNotFound(key, context)
    }
    return index
  }

  func contains(_ key: Key) -> Bool {
    return keys[key.stringValue] != nil
  }

  func decodeNil(forKey key: Key) throws -> Bool {
    fatalError()
  }

  func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
    let index = try columnIndex(forKey: key)
    let type = SQLiteType(rawValue: sqlite3_column_type(statement.handle, index))!
    guard type == .INTEGER else {
      let message = "Expected to decode \(Bool.self) (\(SQLiteType.INTEGER)) but found \(type)"
      throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: message)
    }
    return sqlite3_column_int(statement.handle, index) != 0
  }

  func decode(_ type: String.Type, forKey key: Key) throws -> String {
    let index = try columnIndex(forKey: key)
    let type = SQLiteType(rawValue: sqlite3_column_type(statement.handle, index))!
    guard type == .TEXT else {
      let message = "Expected to decode \(String.self) (\(SQLiteType.TEXT)) but found \(type)"
      throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: message)
    }
    if let text = sqlite3_column_text(statement.handle, index) {
      return String(cString: text)
    } else {
      if let error = database.error {
        throw error
      } else {
        let message = "Expected \(String.self) (SQLITE_TEXT) value but found NULL instead."
        let context = DecodingError.Context(codingPath: codingPath + [key], debugDescription: message)
        throw DecodingError.valueNotFound(String.self, context)
      }
    }
  }

  func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
    fatalError()
  }

  func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
    fatalError()
  }

  func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
    fatalError()
  }

  func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
    fatalError()
  }

  func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
    fatalError()
  }

  func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
    fatalError()
  }

  func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
    fatalError()
  }

  func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
    fatalError()
  }

  func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
    fatalError()
  }

  func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
    fatalError()
  }

  func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
    fatalError()
  }

  func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
    fatalError()
  }

  func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
    fatalError()
  }

  func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
    fatalError()
  }

  func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
    fatalError()
  }

  func superDecoder() throws -> Decoder {
    fatalError()
  }

  func superDecoder(forKey key: Key) throws -> Decoder {
    fatalError()
  }
}
