import SQLite

func printGreetings(in database: Database) throws {
  var query = try database.execute("SELECT text, is_friendly FROM greetings;", as: Greeting.self)
  var results: [Greeting] = []
  while let greeting = try query.next() {
    results.append(greeting)
  }

  if results.isEmpty {
    print("No greetings")
  } else {
    print("Greetings:")
    for greeting in results {
      print("- \(greeting)")
    }
  }
}
