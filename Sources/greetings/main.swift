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
  let parameters = try Parameters(arguments: CommandLine.arguments)
  let database = try Database(createIfNecessaryAtPath: parameters.path)

  try database.execute(
    """
    CREATE TABLE IF NOT EXISTS greetings (
      text TEXT NOT NULL,
      is_friendly INTEGER DEFAULT 0
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
