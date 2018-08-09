//
//  AuthUserController.swift
//  AuthUser
//
//  Created by Michael Housh on 8/3/18.
//

import Vapor
import Authentication
import SimpleController

public protocol AuthUserControllable: RouteCollection {
    
    associatedtype User: AuthUserSupporting
    
    /// The path used to register routes.
    var path: [PathComponentsRepresentable] { get }
    
    /// The `RouteCollection` that will handle most of the routes.
    var collection: ModelRouteCollection<User> { get }
    
    /// `Middleware` to be used during the creation of a new
    /// `AuthUser`.
    var createMiddleware: [Middleware] { get }
    
    /// `Middleware` to be used for all the other routes.
    var middleware: [Middleware] { get }
    
    /// Handler used for creating a new `AuthUser`
    func createHandler(_ request: Request) throws -> Future<User>
}

/// Defaults
extension AuthUserControllable where User.ResolvedParameter == Future<User> {
    
    public var createMiddleware: [Middleware] {
        return []
    }
    
    public func boot(router: Router) throws {
        /// public
        router.get(path, use: collection.getHandler)

        /// authenticated routes
        let authed = router.grouped(middleware)
        authed.get(path, User.parameter, use: collection.getByIdHandler)
        authed.put(path, User.parameter, use: collection.updateHandler)
        authed.delete(path, User.parameter, use: collection.deleteHandler)
        
        /// special for creating users.
        let createGroup = router.grouped(createMiddleware)
        createGroup.post(path, use: createHandler)
    }
    
    public func createHandler(_ request: Request) throws -> Future<User> {
        return try request.content.decode(User.self).flatMap { model in
            var user = model
            user.password = try User.hashPassword(user.password)
            return user.save(on: request)
        }
    }

}

extension Array where Element == AuthMiddlewareType {
    
    static func `default`() -> [AuthMiddlewareType] {
        return [.session, .basic, .login, .authOwner, .guardAuth]
    }
}

open class AuthUserController<A>:AuthUserControllable where A: AuthUserSupporting, A.ResolvedParameter == Future<A> {
    
    public typealias User = A
    
    public var collection: ModelRouteCollection<User>
    
    public var path: [PathComponentsRepresentable] {
        return self.collection.path
    }
    
    public var middleware: [Middleware]
    
    init(path: PathComponentsRepresentable...,
        using middleware: [AuthMiddlewareType]? = nil) {
        
        let middlewares = middleware ?? .default()
        
        self.middleware = middlewares.authMiddleware(User.self)
        
        self.collection = ModelRouteCollection(
            User.self,
            path: path,
            using: self.middleware
        )
    }
    
}
