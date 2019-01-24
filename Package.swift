// swift-tools-version:4.2

import PackageDescription

let package = Package(
  name: "swift-sqlite",
  targets: [
    .target(name: "swift-sqlite", dependencies: ["SQLite"]),
    .target(name: "SQLite", dependencies: ["CSQLite"]),
    .systemLibrary(name: "CSQLite", pkgConfig: "sqlite3", providers: [
      .brew(["sqlite"]),
    ]),
    .testTarget(name: "swift-sqliteTests", dependencies: ["swift-sqlite"]),
  ]
)
