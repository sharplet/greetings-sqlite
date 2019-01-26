import Darwin.sysexits

enum GreetingsError: ConsoleError {
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
