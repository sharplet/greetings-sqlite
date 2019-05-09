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

extension Database {
  public static func select<Table: Selectable>(
    _: Table.Type,
    using makeSQL: (_ columns: Table.Columns.Type) -> RawQuery<Table>
  ) -> Select<Table, Void> {
    return select(Table.self, parameters: Void.self, using: makeSQL)
  }

  public static func select<Table: Selectable, Parameters>(
    _: Table.Type,
    parameters _: Parameters.Type,
    using makeSQL: (_ columns: Table.Columns.Type) -> RawQuery<Table>
  ) -> Select<Table, Parameters> {
    return try! Select(sql: makeSQL(Table.Columns.self).sql, in: .current)
  }
}
