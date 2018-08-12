//
//  PublicUser.swift
//  AuthUser
//
//  Created by Michael Housh on 8/11/18.
//

import Vapor
import Fluent

public struct PublicUser<D>: Content where D: QuerySupporting & JoinSupporting {
    
    public let id: UUID?
    public let username: String
    public let roles: [String]
    
    public static func convert(_ user: AuthUser<D>, on conn: DatabaseConnectable) throws -> Future<PublicUser<D>> {
        
        return try user.roles.query(on: conn).all().map { roles in
            let roleNames = roles.map { $0.name }
            return PublicUser<D>(
                id: user.id,
                username: user.username,
                roles: roleNames
            )
        }
    }
    
    public static func syncConvert(_ user: AuthUser<D>, on conn: DatabaseConnectable) throws -> PublicUser<D> {
        return try convert(user, on: conn).wait()
    }
    
    public func user(on conn: DatabaseConnectable) throws -> Future<AuthUser<D>> {
        guard let id = self.id else {
            throw Abort(.badRequest)
        }
        
        return AuthUser<D>.find(id, on: conn)
            .unwrap(or: Abort(.notFound))
        
    }
}
