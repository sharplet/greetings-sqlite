import SQLite

struct Greeting {
  var isFriendly: Bool
  var text: String
}

extension Greeting: CustomStringConvertible {
  var description: String {
    return "\(text)\(isFriendly ? "!" : "")"
  }
}

extension Greeting: Decodable, Queryable {
  enum CodingKeys: String, CodingKey {
    case text
    case isFriendly = "is_friendly"
  }
}

extension Greeting: Insertable {
  struct Parameters: QueryParametersProtocol {
    typealias CodingKeys = Greeting.CodingKeys

    var text: String
    var isFriendly: Bool
  }

  struct TextParameters: Encodable {
    var text: String
  }

  static func insert(text: String, isFriendly: Bool?) throws -> Query<Int64> {
    if let isFriendly = isFriendly {
      return try insert.bind(.init(text: text, isFriendly: isFriendly))
    } else {
      return try insertWithDefaults.bind(.init(text: text))
    }
  }

  static let insert: Insert<Greeting, Parameters> = try! Insert(
    sql: """
      INSERT INTO greetings (text, is_friendly)
      VALUES (:text, :is_friendly)
      """,
    in: .current
  )

  static let insertWithDefaults = try! Insert<Greeting, TextParameters>(
    sql: """
      INSERT INTO greetings (text)
      VALUES (:text)
      """,
    in: .current
  )
}
