//
//  AuthUserSupporting.swift
//  AuthUser
//
//  Created by Michael Housh on 8/10/18.
//

import Vapor
import Authentication
import Fluent


public protocol AuthUserSupporting: Model, Parameter, Content, PasswordAuthenticatable, SessionAuthenticatable {
    
    var id: UUID? { get set }
    var username: String { get set }
    var password: String { get set }
    
    static func hashPassword(_ password: String) throws -> String
    
}

extension AuthUserSupporting {
    
    /// See `PasswordAuthenticatable`
    public static var usernameKey: UsernameKey { return \.username }
    public static var passwordKey: PasswordKey { return  \.password }
    
    /// See `AuthUserSupporting`
    public static func hashPassword(_ password: String) throws -> String {
        return try BCrypt.hash(password)
    }
}
