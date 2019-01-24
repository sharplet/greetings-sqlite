import XCTest

extension swift_sqliteTests {
  static let __allTests = [
    ("testExample", testExample),
  ]
}

#if !os(macOS)
  public func __allTests() -> [XCTestCaseEntry] {
    return [
      testCase(swift_sqliteTests.__allTests),
    ]
  }
#endif
