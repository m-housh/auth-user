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
    
    associatedtype D: Database
    
    var app: Application! { get }
    var path: String { get }
    var expectedDeleteCode: UInt { get }

    
}

/// Test Handlers.
extension AuthUserTestable where D: QuerySupporting & MigrationSupporting {
    
    public var path: String { return "user" }
    
    public var expectedDeleteCode: UInt { return 200 }
    
    public var users: [AuthUser<D>] {
        return [
            AuthUser<D>(username: "foo", password: "bar"),
            AuthUser<D>(username: "bar", password: "foo"),
            AuthUser<D>(username: "qux", password: "quack")
        ]
    }
    
    private func create(_ user: AuthUser<D>) throws -> AuthUser<D> {
        return try app.getResponse(
            to: path,
            method: .POST,
            headers: .init(),
            data: user,
            decodeTo: AuthUser<D>.self
        )
    }
    
    private func createAll() throws -> [AuthUser<D>] {
        var users: [AuthUser<D>] = []
        for u in self.users {
            users.append(try create(u))
        }
        return users
    }
    
    private func authHeaders(_ user: AuthUser<D>) throws -> HTTPHeaders {
        let user = self.users.first {
            $0.username == user.username }!
        
        var headers = HTTPHeaders()
        headers.basicAuthorization = BasicAuthorization(username: user.username, password: user.password)
        return headers
    }
    
    public func createUsers() throws {
        for user in users {
            let resp = try create(user)
            XCTAssertNotNil(resp.id)
        }
    }
    
    public func getByID() throws {
        let users = try createAll()
            
        XCTAssertEqual(users.count, self.users.count)
            
        for user in users {
            let resp = try app.getResponse(
                to: "\(path)/\(user.id!)",
                headers: try authHeaders(user),
                decodeTo: AuthUser<D>.self
            )
            XCTAssertEqual(resp.id, user.id)
        }
    }
    
    public func getAll() throws {
        let users = try createAll()
        
        let resp = try app.getResponse(to: path, decodeTo: [AuthUser<D>].self)
        XCTAssertEqual(users.count, resp.count)
    }
    
    public func delete() throws {
        let users = try createAll()
        for user in users {
            let resp = try app.sendRequest(
                to: "\(path)/\(user.id!)",
                method: .DELETE,
                headers: try authHeaders(user)
            )
            XCTAssertEqual(resp.http.status.code, expectedDeleteCode)
        }
    }
    
    public func update() throws {
        let users = try createAll()
        
        for (i, user) in users.enumerated() {
            let username = "\(user.username)-\(i)"
            let headers = try authHeaders(user)
            user.username = username
            let resp = try app.getResponse(
                to: "\(path)/\(user.id!)",
                method: .PUT,
                headers: headers,
                data: user,
                decodeTo: AuthUser<D>.self
            )
            
            XCTAssertEqual(resp.username, username)
        }
    }
}


extension AuthUserTestable where D: QuerySupporting & MigrationSupporting {
    
    /// See `VaporTestable`.
    public func routes(_ router: Router) throws {
        let controller = AuthUserController<AuthUser<D>>(path: path)
        try router.register(collection: controller)
    }
}


extension AuthUserTestable where Self: DatabaseRegisterable {
    
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
