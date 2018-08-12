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

open class AuthUserController<D> where D: JoinSupporting {
    
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
    public typealias DBModel = AuthUser<D>
    
    /// Here for testing, but needs to be permanent that all
    /// routes return a `PublicUser`.
    public func getByID(_ request: Request) throws -> Future<PublicUser<D>> {
        return try getByIdHandler(request).flatMap { user in
            return try PublicUser<D>.convert(user, on: request)
        }
    }
    
    public func create(_ request: Request) throws -> Future<PublicUser<D>> {
        return try createHandler(request).flatMap { user in
            return try PublicUser<D>.convert(user, on: request)
        }
    }
    
    public func addRole(_ request: Request) throws -> Future<PublicUser<D>> {
        return try getByIdHandler(request).flatMap{ user in
            return try request.parameters.next(Role<D>.self).flatMap { role in
                return user.roles.attach(role, on: request).flatMap { _ in
                    return try PublicUser<D>.convert(user, on: request)
                }
            }
        }
    }

    /*
    public func get(_ r: Request) throws -> Future<[PublicUser<D>]> {
        return try getHandler(r).map { users in
            var p = [PublicUser<D>]()
            for u in users {
                p.append(try PublicUser<D>.syncConvert(u, on: r))
            }
            return p
        }
    }*/
    
    /// See `RouteCollection`.
    public func boot(router: Router) throws {
        /// public
        /// TODO: Remove this path or protect w/ admin role.
        router.get(path, use: getHandler)
        
        /// for testing
        /// TODO: remove this path.
        router.get(path, DBModel.parameter, "public", use: getByID)
        router.get(path, DBModel.parameter, "addRole", Role<D>.parameter, use: addRole)
        
        /// authenticated routes
        let authed = router.grouped(middleware)
        authed.get(path, DBModel.parameter, use: getByIdHandler)
        authed.put(path, DBModel.parameter, use: updateHandler)
        authed.delete(path, DBModel.parameter, use: deleteHandler)
        
        /// special for creating users.
        let createGroup = router.grouped(createMiddleware)
        createGroup.post(path, use: create)
    }
}
