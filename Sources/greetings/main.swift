import Foundation
import SQLite

func fail(_ error: Swift.Error) -> Never {
  fail(error.localizedDescription, status: error.exitStatus)
}

func fail(_ message: String, status: Int32) -> Never {
  fputs("\(CommandLine.arguments[0]): \(message)\n", stderr)
  exit(status)
}

func main() throws {
  let arguments = CommandLine.arguments.dropFirst()

  guard let path = arguments.first else {
    throw GreetingsError.missingPath
  }

  let database = try Database(createIfNecessaryAtPath: path)
  try database.execute("CREATE TABLE IF NOT EXISTS greetings (text TEXT);")

  var results: [String] = []
  try database.execute("SELECT text FROM greetings;") { row in
    results.append(row["text"]!)
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

do {
  try main()
} catch {
  fail(error)
}
