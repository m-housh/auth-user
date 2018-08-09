//
//  AuthUserController.swift
//  AuthUser
//
//  Created by Michael Housh on 8/3/18.
//

import Vapor
import Authentication
import SimpleController

public protocol AuthUserControllable: ModelControllable {
    
    /// The path used to register routes.
    var path: [PathComponentsRepresentable] { get }
    
    /// `Middleware` to be used during the creation of a new
    /// `AuthUser`.
    var createMiddleware: [Middleware] { get }
    
    /// `Middleware` to be used for all the other routes.
    var middleware: [Middleware] { get }
    
}

/// Defaults
extension AuthUserControllable where DBModel: AuthUserSupporting, DBModel.ResolvedParameter == Future<DBModel> {
    
    /// See `ModelControllable`.
    public func createHandler(_ request: Request) throws -> Future<DBModel> {
        return try request.content.decode(DBModel.self).flatMap { model in
            var user = model
            user.password = try DBModel.hashPassword(user.password)
            return user.save(on: request)
        }
    }

}


extension Array where Element == AuthMiddlewareType {
    
    fileprivate static func `default`() -> [AuthMiddlewareType] {
        return [.session, .basic, .login, .authOwner, .guardAuth]
    }
}

open class AuthUserController<A> where A: AuthUserSupporting, A.ResolvedParameter == Future<A> {
    
    public let path: [PathComponentsRepresentable]
    
    public let middleware: [Middleware]
    
    public let createMiddleware: [Middleware]
    
    public init(path: PathComponentsRepresentable...,
        using middleware: [AuthMiddlewareType]? = nil,
        createMiddleware: [Middleware] = []) {
        
        self.path = path
        self.createMiddleware = createMiddleware
        
        let middlewares = middleware ?? .default()
        
        self.middleware = middlewares.authMiddleware(DBModel.self)
    }
    
   
}

extension AuthUserController: AuthUserControllable, RouteCollection {
    
    /// See `ModelControllable`.
    public typealias DBModel = A

    /// See `RouteCollection`.
    public func boot(router: Router) throws {
        /// public
        router.get(path, use: getHandler)
        
        /// authenticated routes
        let authed = router.grouped(middleware)
        authed.get(path, DBModel.parameter, use: getByIdHandler)
        authed.put(path, DBModel.parameter, use: updateHandler)
        authed.delete(path, DBModel.parameter, use: deleteHandler)
        
        /// special for creating users.
        let createGroup = router.grouped(createMiddleware)
        createGroup.post(path, use: createHandler)
    }
}
