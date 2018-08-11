//
//  AuthUserTesterTests.swift
//  AuthUserTests
//
//  Created by Michael Housh on 8/9/18.
//

import XCTest
import Authentication
import Vapor
import FluentSQLite
import VaporTestable
@testable import AuthUser
@testable import AuthUserTester


final class AuthTester: XCTestCase, AuthUserTestable, DatabaseRegisterable {
    
    /// See `DatabaseRegisterable`
    func registerDatabase(_ services: inout Services) throws {
        try services.register(FluentSQLiteProvider())
        var databases = DatabasesConfig()
        let sqlite = try SQLiteDatabase(storage: .memory)
        databases.add(database: sqlite, as: .sqlite)
        services.register(databases)
    }
    
    /// See `DatabaseRegisterable`
    func registerMigrations(_ services: inout Services) {
        var migrations = MigrationConfig()
        migrations.add(model: AuthUser<SQLiteDatabase>.self, database: .sqlite)
        services.register(migrations)
    }
    
    // See `AuthUserTestable`
    typealias Database = SQLiteDatabase

    
    var app: Application!
    var tester: AuthUserTester<SQLiteDatabase>!
    
    // See `AuthUserTestable`
    var path: String = "user"
    
    
    override func setUp() {
        perform {
            app = try! makeApplication()
            tester = AuthUserTester<SQLiteDatabase>(
                app: app,
                path: path
            )
        }
    }
    
    override func tearDown() {
        perform {
            try self.revert()
        }
    }
    
    //var expectedDeleteCode: UInt = 200
    
    
    func testCreateAll() {
        perform { try tester.createUsers() }
    }
    
    func testGetByID() {
        perform { try tester.getByID() }
    }
    
    func testGetAll() {
        perform { try tester.getAll() }
    }
    
    func testDelete() {
        perform { try tester.delete() }
    }
    
    func testUpdate() {
        perform { try tester.update() }
    }
    
    static var allTests = [
        ("testCreateAll", testCreateAll),
        ("testGetByID", testGetByID),
        ("testGetAll", testGetAll),
        ("testDelete", testDelete),
        ("testUpdate", testUpdate)
    ]
}
