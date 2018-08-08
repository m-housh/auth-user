// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AuthUser",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "AuthUser",
            targets: ["AuthUser"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        
        // Fluent
        .package(url: "https://github.com/vapor/fluent.git", from: "3.0.0"),
        
        // Authentication
        .package(url: "https://github.com/vapor/auth.git", from:"2.0.0-rc.5"),
        
        // Vapor-Testable
        .package(url: "https://github.com/m-housh/vapor-testable.git", from: "0.1.1"),
        
        // SimpleController
        .package(url: "https://github.com/m-housh/simplecontroller.git", from: "0.1.7"),
        
        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0-rc.2"),
        
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "AuthUser",
            dependencies: ["Vapor", "Fluent", "SimpleController", "Authentication"]),
        .testTarget(
            name: "AuthUserTests",
            dependencies: ["AuthUser", "VaporTestable", "FluentSQLite"]),
    ]
)
