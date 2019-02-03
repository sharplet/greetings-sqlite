import SQLite

func addGreeting(_ text: String, isFriendly: Bool?, in database: Database) throws -> Greeting {
  let insertGreeting = try Greeting.insert(text: text, isFriendly: isFriendly)

  var greeting: Greeting?

  try database.execute(insertGreeting) { id in
    let find = try Greeting.find(byRowID: id)
    try database.execute(find) { greeting = $0 }
  }

  return greeting!
}
