//
//  Role.swift
//  AuthUser
//
//  Created by Michael Housh on 8/11/18.
//

import Vapor
import Fluent


public final class Role<D>: Model where D: QuerySupporting {
    
    public typealias Database = D
    
    public typealias ID = UUID
    
    public static var idKey: WritableKeyPath<Role<D>, UUID?> {
        return \.id
    }
    
    public var id: UUID?
    public var name: String
    
    public init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
    
}

extension Role: RoleSupporting { }

extension Role: Migration, AnyMigration where D: MigrationSupporting & SchemaSupporting {
    
    public static func prepare(on conn: D.Connection) -> EventLoopFuture<Void> {
        return D.create(Role<D>.self, on: conn) { builder in
            try addProperties(to: builder)
            builder.unique(on: \.name)
        }
    }
    
    public static func revert(on conn: D.Connection) -> EventLoopFuture<Void> {
        return D.delete(Role<D>.self, on: conn)
    }
    
}

extension Role {
    
    private static func _findOrCreate(_ name: String, on conn: DatabaseConnectable) throws -> Future<Role> {
        return Role.query(on: conn).filter(\.name == name).first().map { weakRole in
            if let strongRole = weakRole {
                return strongRole
            }
            return Role(name: name)
        }
    }
    
    public static func findOrCreate(_ name: String, on conn: DatabaseConnectable) throws -> Future<Role> {
        return try Role._findOrCreate(name, on: conn).flatMap { role in
            if let _ = role.id {
                return conn.future(role)
            }
            return role.save(on: conn)
        }
    }
}
