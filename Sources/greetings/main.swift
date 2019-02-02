import Foundation
import SQLite

struct Parameters {
  var isFriendly: Bool?
  var newGreeting: String?
  var path: String
}

enum ParsingMode {
  case option
  case argument(String, (String) -> Void)
}

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

func parse<Arguments: RangeReplaceableCollection>(_ arguments: Arguments, dropFirst: Bool = true) throws -> Parameters
  where Arguments.Element == String {

  var arguments = dropFirst ? arguments.dropFirst() : arguments[...]
  var mode = ParsingMode.option
  var isFriendly: Bool?
  var newGreeting: String?

  arguments.removeAll { argument -> Bool in
    switch (mode, argument) {
    case let (.argument(_, setValue), value):
      setValue(value)
      mode = .option
      return true

    case let (_, name) where name == "-a" || name == "--add":
      mode = .argument(name) { newGreeting = $0 }
      return true

    case (_, "--friendly"):
      isFriendly = true
      return true

    default:
      return false
    }
  }

  if case let .argument(name, _) = mode {
    throw GreetingsError.missingRequiredArgument(name)
  }

  guard let path = arguments.first else {
    throw GreetingsError.missingPath
  }

  return Parameters(
    isFriendly: isFriendly,
    newGreeting: newGreeting,
    path: path
  )
}

func main() throws {
  let parameters = try parse(CommandLine.arguments)
  let database = try Database(createIfNecessaryAtPath: parameters.path)

  try database.execute(
    """
    CREATE TABLE IF NOT EXISTS greetings (
      text TEXT NOT NULL,
      is_friendly INTEGER DEFAULT 0
    );
    """
  )

  if let newGreeting = parameters.newGreeting {
    try addGreeting(newGreeting, isFriendly: parameters.isFriendly, in: database)
  } else {
    try printGreetings(in: database)
  }
}

func addGreeting(_ text: String, isFriendly: Bool?, in database: Database) throws {
  let statement: SQLTemplate
  if let isFriendly = isFriendly {
    statement = "INSERT INTO greetings (text, is_friendly) VALUES (\(text), \(isFriendly));"
  } else {
    statement = "INSERT INTO greetings (text) VALUES (\(text));"
  }

  try database.execute(statement)

  guard let id = database.lastInsertedRowID else {
    assertionFailure("Expected a non-zero row ID")
    return
  }

  var result = try database.execute("SELECT text, is_friendly FROM greetings WHERE rowid = \(id);", as: Greeting.self)
  while let g = try result.next() {
    print("Inserted: \(g)")
  }
}

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

do {
  try main()
} catch {
  fail(error)
}
