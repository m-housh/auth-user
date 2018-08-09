//
//  AuthMiddleware.swift
//  AuthUser
//
//  Created by Michael Housh on 8/8/18.
//

import Vapor
import Authentication


public enum AuthMiddlewareType {
    case basic
    case session
    case authOwner
    case guardAuth
    case login
    
    public func middleware<A>(using type: A.Type) -> Middleware where A: AuthUserSupporting, A.ResolvedParameter == Future<A> {
        
        switch self {
        case .basic:
            return type.basicAuthMiddleware(using: BCrypt)
        case .session:
            return type.authSessionsMiddleware()
        case .authOwner:
            return AuthOwnerMiddleware<A>()
        case .guardAuth:
            return type.guardAuthMiddleware()
        case .login:
            return type.loginRedirectMiddleware()
        }
        
    }
}

public struct AuthMiddleware<A> where A: AuthUserSupporting, A.ResolvedParameter == Future<A> {
    
    private let authUser: A.Type
    private let middlewares: [AuthMiddlewareType]
    
    public var middleware: [Middleware] {
        var middleware = middlewares.map { $0.middleware(using: authUser) }
        middleware.append(authUser.guardAuthMiddleware())
        return middleware
        
    }
    
    init(_ type: A.Type = A.self, using middleware: [AuthMiddlewareType]) {
        self.authUser = type
        self.middlewares = middleware
    }
    
}

extension Array where Element == AuthMiddlewareType {
    
    func authMiddleware<A>(_ type: A.Type) -> [Middleware] where A: AuthUserSupporting, A.ResolvedParameter == Future<A> {
        return AuthMiddleware(type, using: self).middleware
    }
}


