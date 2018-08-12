//
//  RoleController.swift
//  AuthUser
//
//  Created by Michael Housh on 8/11/18.
//

import Vapor
import SimpleController
import Fluent


public final class RoleController<D> where D: QuerySupporting & JoinSupporting {
    
    
    public var path: [PathComponentsRepresentable]
    public var middleware: [Middleware]
    
    public init(path: PathComponentsRepresentable..., middleware: [Middleware] = []) {
        self.path = path
        self.middleware = middleware
    }
}

extension RoleController {
    
    public func addUserHandler(_ request: Request) throws -> Future<DBModel> {
        
        return try request.content.decode(PublicUser<D>.self).flatMap { publicUser in
            return try publicUser.user(on: request)
        }
        .flatMap { user in
            return try request.parameters.next(DBModel.self).flatMap { role in
                return user.roles.attach(role, on: request)
                    .transform(to: role)
            }
        }
    }
    
    public func findOrCreateHandler(_ request: Request) throws -> Future<DBModel> {
        let name = try request.parameters.next(String.self)
        return try Role<D>.findOrCreate(name, on: request)
    }
}

extension RoleController: ModelControllable, RouteCollection {
    
    public typealias DBModel = Role<D>
    
    public func boot(router: Router) throws {
        let group = router.grouped(middleware)
        group.get(path, use: getHandler)
        group.get(path, DBModel.parameter, use: getByIdHandler)
        group.post(path, use: createHandler)
        group.put(path, DBModel.parameter, use: updateHandler)
        group.delete(path, DBModel.parameter, use: deleteHandler)
        group.post(path, DBModel.parameter, use: addUserHandler)
        group.get(path, "findOrCreate", String.parameter, use: findOrCreateHandler)
    }
}
