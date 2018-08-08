//
//  AuthOwnerMiddleware.swift
//  AuthUser
//
//  Created by Michael Housh on 8/4/18.
//

import Vapor
import Fluent

/// Only allows retrieval of items that match the `id` of the
/// authenticated user.
///
/// This prevents users from viewing other users.
public protocol AuthOwnerMiddlewareSupporting: Middleware {
    associatedtype AuthUser: AuthUserSupporting
}

extension AuthOwnerMiddlewareSupporting where AuthUser.ResolvedParameter == Future<AuthUser> {
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        
        /// Get the authenticated user for the request
        let authenticatedUser = try request.requireAuthenticated(AuthUser.self)
        
        /// Check the authenticated user's id matches the id
        /// used in the route.
        guard let uuid = UUID(request.parameters.values[0].value),
            let id = authenticatedUser.id,
            uuid == id else {
                /// Id's don't match
                throw Abort(.unauthorized)
        }
        /// Id's match.
        return try next.respond(to: request)
       
    }
}

public final class AuthOwnerMiddleware<A>: AuthOwnerMiddlewareSupporting where A: AuthUserSupporting, A.ResolvedParameter == Future<A> {

    public typealias AuthUser = A
}


/*
public final class AuthOwnerMiddleware<A>: Middleware where A: AuthUserSupporting & Parameter {
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        guard let user = try request.authenticated(A.self) else {
            throw Abort(.unauthorized)
        }
        
        return try request.parameters.next(A.self).flatMap { model in
            if model.id == user.id {
                return try next.respond(to: request)
            }
            throw Abort(.unauthorized)
        }
    }
    
    
}*/
