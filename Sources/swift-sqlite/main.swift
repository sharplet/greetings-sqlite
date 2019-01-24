import SQLite
import Foundation

protocol ConsoleError: LocalizedError {
  var statusCode: Int32? { get }
}

extension Swift.Error {
  var exitStatus: Int32 {
    return (self as? ConsoleError)?.statusCode ?? EX_SOFTWARE
  }
}

enum Error: ConsoleError {
  case missingPath

  var errorDescription: String? {
    switch self {
    case .missingPath:
      return "Please specify a database file"
    }
  }

  var statusCode: Int32? {
    switch self {
    case .missingPath:
      return EX_USAGE
    }
  }
}

func fail(_ error: Swift.Error) -> Never {
  fail(error.localizedDescription, status: error.exitStatus)
}

func fail(_ message: String, status: Int32) -> Never {
  fputs("\(CommandLine.arguments[0]): \(message)\n", stderr)
  exit(status)
}

let arguments = Array(CommandLine.arguments.dropFirst())

func main() throws {
  guard let path = arguments.first else {
    throw Error.missingPath
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
