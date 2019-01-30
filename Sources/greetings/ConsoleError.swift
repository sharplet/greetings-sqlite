import Darwin.sysexits
import protocol Foundation.LocalizedError
import class Foundation.NSError
import let Foundation.NSFilePathErrorKey

protocol ConsoleError: LocalizedError {
  var statusCode: Int32? { get }
}

extension Error {
  var consoleDescription: String {
    if let path = (self as NSError).userInfo[NSFilePathErrorKey] {
      return "\(path): \(localizedDescription)"
    } else {
      return localizedDescription
    }
  }

  var exitStatus: Int32 {
    return (self as? ConsoleError)?.statusCode ?? EX_SOFTWARE
  }
}
