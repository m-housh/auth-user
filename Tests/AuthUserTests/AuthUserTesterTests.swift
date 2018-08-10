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
@testable import AuthUser
@testable import AuthUserTester


final class AuthTester: XCTestCase, DatabaseRegisterable, AuthUserTestable  {
    
    func registerDatabase(_ services: inout Services) throws {
        try services.register(FluentSQLiteProvider())
        var databases = DatabasesConfig()
        let sqlite = try SQLiteDatabase(storage: .memory)
        databases.add(database: sqlite, as: .sqlite)
        services.register(databases)
    }
    
    func registerMigrations(_ services: inout Services) {
        var migrations = MigrationConfig()
        migrations.add(model: AuthUser<SQLiteDatabase>.self, database: .sqlite)
        services.register(migrations)
    }
    
    
    var app: Application!
    
    typealias D = SQLiteDatabase
    
    override func setUp() {
        perform {
            app = try! makeApplication()
        }
    }
    
    override func tearDown() {
        perform {
            try self.revert()
        }
    }
    
    //var expectedDeleteCode: UInt = 200
    
    
    func testCreateAll() {
        perform { try createUsers() }
    }
    
    func testGetByID() {
        perform { try getByID() }
    }
    
    func testGetAll() {
        perform { try getAll() }
    }
    
    func testDelete() {
        perform { try delete() }
    }
    
    func testUpdate() {
        perform { try update() }
    }
    
    static var allTests = [
        ("testCreateAll", testCreateAll),
        ("testGetByID", testGetByID),
        ("testGetAll", testGetAll),
        ("testDelete", testDelete),
        ("testUpdate", testUpdate)
    ]
}
