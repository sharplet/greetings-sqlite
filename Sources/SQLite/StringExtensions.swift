extension String {
  func firstLetterUppercased() -> String {
    guard let letter = firstIndex(where: { $0.isLetter }), !self[letter].isUppercase else { return self }

    var result = String(self[..<letter])
    result += self[letter].uppercased()
    result += self[index(after: letter)...]
    return result
  }
}
