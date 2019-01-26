import Darwin.sysexits
import protocol Foundation.LocalizedError

protocol ConsoleError: LocalizedError {
  var statusCode: Int32? { get }
}

extension Error {
  var exitStatus: Int32 {
    return (self as? ConsoleError)?.statusCode ?? EX_SOFTWARE
  }
}
