import SQLite

func addGreeting(_ text: String, isFriendly: Bool?, in database: Database) throws -> Greeting {
  let statement: SQLTemplate
  if let isFriendly = isFriendly {
    statement = "INSERT INTO greetings (text, is_friendly) VALUES (\(text), \(isFriendly))"
  } else {
    statement = "INSERT INTO greetings (text) VALUES (\(text))"
  }

  try database.execute(statement)

  let id = database.lastInsertedRowID!
  var result = try database.execute("SELECT text, is_friendly FROM greetings WHERE rowid = \(id)", as: Greeting.self)
  return try result.next()!
}
