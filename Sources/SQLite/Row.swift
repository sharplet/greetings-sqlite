public struct Row {
  typealias CStringVector = UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>
  typealias Tuple = (name: String, value: String)

  let tuples: [Tuple]

  init(count: Int32, columns: CStringVector!, values: CStringVector!) {
    var tuples: [Tuple] = []
    for index in 0 ..< Int(count) {
      let name = String(cString: columns[index]!)
      let value = String(cString: values[index]!)
      tuples.append((name, value))
    }
    self.tuples = tuples
  }

  public subscript(column: String) -> String? {
    return tuples.first(where: { $0.name == column })?.value
  }
}
