//
//  Role+AuthUser.swift
//  AuthUser
//
//  Created by Michael Housh on 8/11/18.
//

import Vapor
import Fluent


public final class UserRole<D>: ModifiablePivot where D: QuerySupporting {
    
    public static var leftIDKey: WritableKeyPath<UserRole<D>, UUID> { return \.userID }
    
    public static var rightIDKey: WritableKeyPath<UserRole<D>, UUID> { return \.roleID }
    
    public static var idKey: WritableKeyPath<UserRole<D>, Int?> { return \.id }
    
    public typealias Left = AuthUser<D>
    
    public typealias Right = Role<D>
    
    public typealias Database = D
    
    public typealias ID = Int
    
    public var id: Int?
    public var userID: AuthUser<D>.ID
    public var roleID: Role<D>.ID
    
    /// See modifiable pivot.
    public init(_ left: AuthUser<D>, _ right: Role<D>) throws {
        self.userID = try left.requireID()
        self.roleID = try right.requireID()
    }
    
}

extension UserRole: Migration, AnyMigration where D: SchemaSupporting & MigrationSupporting {
    
    public static func prepare(on conn: D.Connection) -> EventLoopFuture<Void> {
        return D.create(UserRole<D>.self, on: conn) { builder in
            builder.field(for: \UserRole<D>.id, isIdentifier: true)
            builder.field(for: \UserRole<D>.userID)
            builder.field(for: \UserRole<D>.roleID)
        }
    }
    
    public static func revert(on conn: D.Connection) -> EventLoopFuture<Void> {
        return D.delete(UserRole<D>.self, on: conn)
    }
}

extension Role where D: JoinSupporting {
    
    public var users: Siblings<Role, AuthUser<D>, UserRole<D>> {
        return siblings()
    }
}

extension AuthUser where D: JoinSupporting {
    
    public var roles: Siblings<AuthUser, Role<D>, UserRole<D>> {
        return siblings()
    }
}
