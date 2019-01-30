import Foundation
import SQLite

private let isDebugEnabled: Bool = {
  guard let value = ProcessInfo.processInfo.environment["GREETINGS_DEBUG"] else { return false }
  return (value as NSString).boolValue
}()

private let programName: String = URL(fileURLWithPath: CommandLine.arguments[0]).lastPathComponent

func fail(_ error: Swift.Error) -> Never {
  let message = isDebugEnabled ? "\(error)" : error.consoleDescription
  fail(message, status: error.exitStatus)
}

func fail(_ message: String, status: Int32) -> Never {
  fputs("\(programName): \(message)\n", stderr)
  exit(status)
}

func main() throws {
  let arguments = CommandLine.arguments.dropFirst()

  guard let path = arguments.first else {
    throw GreetingsError.missingPath
  }

  let database = try Database(createIfNecessaryAtPath: path)
  try database.execute("CREATE TABLE IF NOT EXISTS greetings (text TEXT, is_friendly INTEGER);")

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
      print("- \(greeting.text)\(greeting.isFriendly ? "!" : "")")
    }
  }
}

do {
  try main()
} catch {
  fail(error)
}
