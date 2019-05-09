import Foundation
import SQLite

extension ProcessInfo {
  var isDebugEnabled: Bool {
    guard let value = environment["GREETINGS_DEBUG"] else { return false }
    return (value as NSString).boolValue
  }
}

func fail(_ error: Swift.Error) -> Never {
  let message = ProcessInfo.processInfo.isDebugEnabled ? "\(error)" : error.consoleDescription
  fail(message, status: error.exitStatus)
}

func fail(_ message: String, status: Int32) -> Never {
  fputs("\(ProcessInfo.processInfo.processName): \(message)\n", stderr)
  exit(status)
}

func main() throws {
  let parameters = try Parameters(arguments: CommandLine.arguments)
  let database = try Database(createIfNecessaryAtPath: parameters.path)
  Database.setCurrent(database, queue: .main)

  try database.execute(
    """
    CREATE TABLE IF NOT EXISTS greetings (
      text TEXT NOT NULL,
      is_friendly INTEGER NOT NULL DEFAULT 0
    )
    """
  )

  if let newGreeting = parameters.newGreeting {
    let greeting = try addGreeting(newGreeting, isFriendly: parameters.isFriendly, in: database)
    print("Inserted: \(greeting)")
  } else {
    try printGreetings(in: database)
  }
}

do {
  try main()
} catch {
  fail(error)
}
