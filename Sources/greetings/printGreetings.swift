import SQLite

func printGreetings(in database: Database) throws {
  var foundGreetings = false

  try database.execute(Greeting.all) { greeting in
    if !foundGreetings {
      foundGreetings = true
      print("Greetings:")
    }
    print("- \(greeting)")
  }

  if !foundGreetings {
    print("No greetings")
  }
}
