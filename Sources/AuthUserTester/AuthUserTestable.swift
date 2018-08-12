//
//  AuthUserTester.swift
//  AuthUser
//
//  Created by Michael Housh on 8/9/18.
//

import AuthUser
import Fluent
import VaporTestable
import Vapor
import XCTest
import Authentication


public protocol DatabaseRegisterable {
    func registerDatabase(_ services: inout Services) throws -> ()
    func registerMigrations(_ services: inout Services)
}

public protocol AuthUserTestable: VaporTestable {
    
    associatedtype Database: QuerySupporting & MigrationSupporting & JoinSupporting
    var path: String { get }
}



extension AuthUserTestable {
    
    /// See `VaporTestable`.
    public func routes(_ router: Router) throws {
        let controller = AuthUserController<Database>(path: path)
        try router.register(collection: controller)
    }
}


extension VaporTestable where Self: DatabaseRegisterable {
    
    public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
        //try services.register(FluentSQLiteProvider())
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
        try registerDatabase(&services)
        
        /// Configure migrations
        registerMigrations(&services)
        
        /// Command configuration
        var commandConfig = CommandConfig.default()
        commandConfig.useFluentCommands()
        services.register(commandConfig)
        
        config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
    }
}
