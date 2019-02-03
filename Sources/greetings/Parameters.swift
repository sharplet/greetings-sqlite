struct Parameters {
  var isFriendly: Bool?
  var newGreeting: String?
  var path: String
}

extension Parameters {
  private enum ParsingMode {
    case option
    case argument(String, (String) -> Void)
  }

  init<Arguments: RangeReplaceableCollection>(arguments: Arguments, dropFirst: Bool = true) throws where Arguments.Element == String {
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

    self.isFriendly = isFriendly
    self.newGreeting = newGreeting
    self.path = path
  }
}
