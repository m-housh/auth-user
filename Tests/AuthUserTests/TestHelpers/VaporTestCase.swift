//
//  VaporTestCase.swift
//  AuthUserTests
//
//  Created by Michael Housh on 8/3/18.
//

import XCTest
import VaporTestable
import Vapor
import Authentication
import FluentSQLite

@testable import AuthUser

class VaporTestCase: XCTestCase, VaporTestable {
    
    var app: Application!
    
    private func loggedInHandler(_ request: Request) throws -> LoggedInContext {
        let user = try request.requireAuthenticated(TestAuthUser.self)
        return LoggedInContext(for: user)
    }
    
    func routes(_ router: Router) throws {
                
        let loginCollection = TestLoginController(
            redirectingTo: "loggedIn"
            //using: .session, .basic, .authOwner, .guardAuth
        )
        
        let customLogin = TestLoginController(
            using: .basic, .guardAuth
        )
        
        let customGroup = router.grouped("custom")
        try customGroup.register(collection: customLogin)
        
        
        try router.register(collection: loginCollection)
        router.get("loggedIn", use: loggedInHandler)
        
        
        let authUserCollection = TestAuthUserController(path: "user")
        try router.register(collection: authUserCollection)
        
        let authenticated = router.grouped(
            TestAuthUser.authSessionsMiddleware(),
            TestAuthUser.basicAuthMiddleware(using: BCrypt),
            TestAuthUser.loginRedirectMiddleware(),
            TestAuthUser.guardAuthMiddleware()
        )
        authenticated.get("auth") { req -> TestAuthUser in
            return try req.requireAuthenticated(TestAuthUser.self)
        }
        
        
        //try router.register(collection: SQLiteAuthUserController())
        //try router.register(collection: collection)
    }
    
    func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
        try services.register(FluentSQLiteProvider())
        try services.register(AuthenticationProvider())
        
        /// Register routes to the router
        let router = EngineRouter.default()
        try routes(router)
        services.register(router, as: Router.self)
        
        /// Register middleware
        var middlewares = MiddlewareConfig() // Create _empty_ middleware config
        middlewares.use(SessionsMiddleware.self) // for using sessions
        services.register(middlewares)
        
        /// Database
        let sqlite = try SQLiteDatabase(storage: .memory)
        /// Register the configured SQLite database to the database config.
        var databases = DatabasesConfig()
        databases.add(database: sqlite, as: .sqlite)
        services.register(databases)
        
        /// Configure migrations
        var migrations = MigrationConfig()
        migrations.add(model: TestAuthUser.self, database: .sqlite)
        migrations.add(model: TestAuthUser.self, database: .sqlite)
        
        services.register(migrations)
        
        /// Command configuration
        var commandConfig = CommandConfig.default()
        commandConfig.useFluentCommands()
        services.register(commandConfig)
        
        config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
        
    }
    
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
    
}
