//
//  AuthUserToken.swift
//  AuthUser
//
//  Created by Michael Housh on 8/10/18.
//

import Vapor
import Fluent
import Authentication


public protocol AuthUserTokenSupporting: AuthUserSupporting, TokenAuthenticatable { }

public final class TokenAuthUser<D>: AuthUserTokenSupporting where D: MigrationSupporting & QuerySupporting {
    
    public static var idKey: WritableKeyPath<TokenAuthUser<D>, UUID?> { return \.id }
    
    public var id: UUID?
    
    public var username: String
    
    public var password: String
    
    //public var token: String
    
    public typealias TokenType = AuthUserToken<D>
    
    public typealias Database = D
    
    public typealias ID = UUID
    
    public init(id: UUID? = nil, username: String, password: String) {
        self.id = id
        self.username = username
        self.password = password
        //self.token = token
    }
}

extension TokenAuthUser: Parameter, Content { }

public final class AuthUserToken<D>: Model, Token where D: MigrationSupporting & QuerySupporting {
    
    public static var tokenKey: WritableKeyPath<AuthUserToken<D>, String> {
        return \.token
    }
    
    
    public static var userIDKey: WritableKeyPath<AuthUserToken<D>, TokenAuthUser<D>.ID> {
        return \.userID
    }
    
    public static var idKey: WritableKeyPath<AuthUserToken<D>, UUID?> { return \.id }
    
    
    public typealias UserType = TokenAuthUser<D>
    
    public typealias UserIDType = TokenAuthUser<D>.ID
    
    public typealias Database = D
    
    public typealias ID = UUID
    
    public var id: UUID?
    
    public var userID: UserIDType
    
    public var token: String
    
    public init(id: UUID? = nil, userID: UserIDType, token: String) {
        self.id = id
        self.userID = userID
        self.token = token
    }
    
}

extension AuthUserToken: Migration, AnyMigration where D: SchemaSupporting {
    
    public static func prepare(on conn: D.Connection) -> EventLoopFuture<Void> {
        return D.create(AuthUserToken<D>.self, on: conn) { builder in
            
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.userID)
            builder.field(for: \.token)
            
        }
    }
}

/*
public final class AuthUserToken<D>: Token where D: QuerySupporting & MigrationSupporting {
    
    public typealias UserType = AuthUser<D>
    
    
    
}
*/
