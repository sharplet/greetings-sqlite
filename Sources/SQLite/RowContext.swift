import typealias CSQLite.sqlite3_callback

final class RowContext {
  private(set) var error: Error?
  private let handler: (Row) throws -> Void

  init(handler: @escaping (Row) throws -> Void) {
    self.handler = handler
  }

  let callback: sqlite3_callback = { context, count, values, columns in
    let context: RowContext = Unmanaged.fromOpaque(context!).takeUnretainedValue()
    return context.handleRow(count, columns: columns, values: values)
  }

  var pointer: UnsafeMutableRawPointer {
    return Unmanaged.passUnretained(self).toOpaque()
  }

  private func handleRow(_ count: Int32, columns: Row.CStringVector!, values: Row.CStringVector!) -> Int32 {
    let row = Row(count: count, columns: columns, values: values)
    do {
      try handler(row)
      return 0
    } catch {
      self.error = error
      return 1
    }
  }
}
