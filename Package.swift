// swift-tools-version:4.2

import PackageDescription

let package = Package(
  name: "greetings",
  targets: [
    .target(name: "greetings", dependencies: ["SQLite"]),
    .target(name: "SQLite", dependencies: ["CSQLite"]),
    .systemLibrary(name: "CSQLite", pkgConfig: "sqlite3", providers: [
      .brew(["sqlite"]),
    ]),
    .testTarget(name: "GreetingsTests", dependencies: ["greetings"]),
  ]
)
