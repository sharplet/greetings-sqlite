import SQLite

struct Greeting {
  var id: Int64
  var isFriendly: Bool
  var text: String
}

extension Greeting: CustomStringConvertible {
  var description: String {
    return "\(text)\(isFriendly ? "!" : "")"
  }
}

extension Greeting: Queryable {
  enum CodingKeys: String, CodingKey {
    case id = "rowid"
    case text
    case isFriendly = "is_friendly"
  }
}

extension Greeting: Selectable {
  static let find: Select<Greeting, Int64> = try! Select(
    sql: """
      SELECT rowid, text, is_friendly
      FROM greetings
      WHERE rowid = ?
      """,
    in: .current
  )
}

extension Greeting: Insertable {
  struct Parameters: QueryParameters {
    static let bindings: Bindings<Greeting> = [
      .text <- \.text,
      .isFriendly <- \.isFriendly,
    ]

    var text: String
    var isFriendly: Bool
  }

  static func insert(text: String, isFriendly: Bool?) throws -> Query<Int64> {
    if let isFriendly = isFriendly {
      return try insert.bind(.init(text: text, isFriendly: isFriendly))
    } else {
      return try insertText.bind(text)
    }
  }

  static let insert: Insert<Greeting, Parameters> = try! Insert(
    sql: """
      INSERT INTO greetings (text, is_friendly)
      VALUES (:text, :is_friendly)
      """,
    in: .current
  )

  static let insertText = try! Insert<Greeting, String>(
    sql: """
      INSERT INTO greetings (text)
      VALUES (?)
      """,
    in: .current
  )
}
