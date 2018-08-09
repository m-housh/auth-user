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
    
    let middleware: AuthMiddlewareType
    let type: A.Type
    
    init(_ type: A.Type = A.self, _ middleware: AuthMiddlewareType) {
        self.type = type
        self.middleware = middleware
    }
    
}

extension AuthMiddleware: Middleware {
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        return try middleware.middleware(using: type)
            .respond(to: request, chainingTo: next)
    }
}

extension Array where Element == AuthMiddlewareType {
    
    func authMiddleware<A>(_ type: A.Type) -> [Middleware] where A: AuthUserSupporting, A.ResolvedParameter == Future<A> {
        return self.map { AuthMiddleware(type, $0) }
    }
}


