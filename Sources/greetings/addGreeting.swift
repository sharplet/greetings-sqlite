import SQLite

func addGreeting(_ text: String, isFriendly: Bool?, in database: Database) throws -> Greeting {
  let insertGreeting = try Greeting.insert(text: text, isFriendly: isFriendly)

  var greeting: Greeting?
  try database.execute(insertGreeting) { id in
    var result = try database.execute("SELECT text, is_friendly FROM greetings WHERE rowid = \(id)", as: Greeting.self)
    greeting = try result.next()
  }

  return greeting!
}
