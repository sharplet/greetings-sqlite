import Foundation

// swiftformat:disable all
@objc public enum SQLiteErrorCode: Int32 {
//case OK          =  0   /* Successful result */
  case ERROR       =  1   /* Generic error */
  case INTERNAL    =  2   /* Internal logic error in SQLite */
  case PERM        =  3   /* Access permission denied */
  case ABORT       =  4   /* Callback routine requested an abort */
  case BUSY        =  5   /* The database file is locked */
  case LOCKED      =  6   /* A table in the database is locked */
  case NOMEM       =  7   /* A malloc() failed */
  case READONLY    =  8   /* Attempt to write a readonly database */
  case INTERRUPT   =  9   /* Operation terminated by sqlite3_interrupt()*/
  case IOERR       = 10   /* Some kind of disk I/O error occurred */
  case CORRUPT     = 11   /* The database disk image is malformed */
  case NOTFOUND    = 12   /* Unknown opcode in sqlite3_file_control() */
  case FULL        = 13   /* Insertion failed because database is full */
  case CANTOPEN    = 14   /* Unable to open the database file */
  case PROTOCOL    = 15   /* Database lock protocol error */
  case EMPTY       = 16   /* Internal use only */
  case SCHEMA      = 17   /* The database schema changed */
  case TOOBIG      = 18   /* String or BLOB exceeds size limit */
  case CONSTRAINT  = 19   /* Abort due to constraint violation */
  case MISMATCH    = 20   /* Data type mismatch */
  case MISUSE      = 21   /* Library used incorrectly */
  case NOLFS       = 22   /* Uses OS features not supported on host */
  case AUTH        = 23   /* Authorization denied */
  case FORMAT      = 24   /* Not used */
  case RANGE       = 25   /* 2nd parameter to sqlite3_bind out of range */
  case NOTADB      = 26   /* File opened that is not a database file */
  case NOTICE      = 27   /* Notifications from sqlite3_log() */
  case WARNING     = 28   /* Warnings from sqlite3_log() */
//case ROW         = 100  /* sqlite3_step() has another row ready */
//case DONE        = 101  /* sqlite3_step() has finished executing */
}
// swiftformat:enable all

public struct SQLiteError: _BridgedStoredNSError {
  public static let errorDomain = "SQLiteErrorDomain"

  // swiftlint:disable:next identifier_name
  public let _nsError: NSError

  public init(_nsError error: NSError) {
    precondition(error.domain == SQLiteError.errorDomain)
    self._nsError = error
  }

  public typealias Code = SQLiteErrorCode
}

extension SQLiteErrorCode: _ErrorCodeProtocol {
  // swiftlint:disable:next type_name
  public typealias _ErrorType = SQLiteError
}

extension SQLiteError {
  public static var ERROR: SQLiteErrorCode { return .ERROR }
  public static var INTERNAL: SQLiteErrorCode { return .INTERNAL }
  public static var PERM: SQLiteErrorCode { return .PERM }
  public static var ABORT: SQLiteErrorCode { return .ABORT }
  public static var BUSY: SQLiteErrorCode { return .BUSY }
  public static var LOCKED: SQLiteErrorCode { return .LOCKED }
  public static var NOMEM: SQLiteErrorCode { return .NOMEM }
  public static var READONLY: SQLiteErrorCode { return .READONLY }
  public static var INTERRUPT: SQLiteErrorCode { return .INTERRUPT }
  public static var IOERR: SQLiteErrorCode { return .IOERR }
  public static var CORRUPT: SQLiteErrorCode { return .CORRUPT }
  public static var NOTFOUND: SQLiteErrorCode { return .NOTFOUND }
  public static var FULL: SQLiteErrorCode { return .FULL }
  public static var CANTOPEN: SQLiteErrorCode { return .CANTOPEN }
  public static var PROTOCOL: SQLiteErrorCode { return .PROTOCOL }
  public static var EMPTY: SQLiteErrorCode { return .EMPTY }
  public static var SCHEMA: SQLiteErrorCode { return .SCHEMA }
  public static var TOOBIG: SQLiteErrorCode { return .TOOBIG }
  public static var CONSTRAINT: SQLiteErrorCode { return .CONSTRAINT }
  public static var MISMATCH: SQLiteErrorCode { return .MISMATCH }
  public static var MISUSE: SQLiteErrorCode { return .MISUSE }
  public static var NOLFS: SQLiteErrorCode { return .NOLFS }
  public static var AUTH: SQLiteErrorCode { return .AUTH }
  public static var FORMAT: SQLiteErrorCode { return .FORMAT }
  public static var RANGE: SQLiteErrorCode { return .RANGE }
  public static var NOTADB: SQLiteErrorCode { return .NOTADB }
  public static var NOTICE: SQLiteErrorCode { return .NOTICE }
  public static var WARNING: SQLiteErrorCode { return .WARNING }
}
