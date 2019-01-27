struct Greeting {
  var isFriendly: Bool
  var text: String
}

extension Greeting: Decodable {
  private enum CodingKeys: String, CodingKey {
    case text
    case isFriendly = "is_friendly"
  }
}
