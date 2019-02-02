import Foundation

enum GreetingsError: ConsoleError {
  case missingPath
  case missingRequiredArgument(String)

  var errorDescription: String? {
    switch self {
    case .missingPath:
      return NSLocalizedString("Please specify a database file", comment: "Message when path to database not specified")

    case let .missingRequiredArgument(name):
      let format = NSLocalizedString("Option '%@' requires an argument", comment: "Message when required argument is missing")
      return String(format: format, name)
    }
  }

  var statusCode: Int32? {
    switch self {
    case .missingPath,
         .missingRequiredArgument:
      return EX_USAGE
    }
  }
}
