extension String {
  func firstLetterUppercased() -> String {
    guard let first = first, first.isLowercase else { return self }
    return String(first).uppercased() + dropFirst()
  }
}
