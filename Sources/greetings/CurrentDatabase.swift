import Dispatch
import SQLite

extension Database {
  private static let databaseKey = DispatchSpecificKey<Database>()

  static var current: Database {
    guard let database = DispatchQueue.getSpecific(key: databaseKey) else {
      preconditionFailure("Database not initialised")
    }
    return database
  }

  static func setCurrent(_ database: Database, queue: DispatchQueue) {
    queue.setSpecific(key: databaseKey, value: database)
  }
}
