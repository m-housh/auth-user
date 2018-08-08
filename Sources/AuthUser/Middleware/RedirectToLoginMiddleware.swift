//
//  LoginRedirectMiddleware.swift
//  AuthUser
//
//  Created by Michael Housh on 8/3/18.
//

import Vapor
import Authentication

/// This middleware can be used to redirect to a login route.
/// This middleware should be one of the last if the authentication
/// middleware chains, so that other `Middleware` can authenticate a
/// route.
public final class RedirectToLoginMiddleware<A>: Middleware where A: Authenticatable {
    
    /// The path to redirect to for login.
    private let path: String
    
    init(_ type: A.Type = A.self, path: String = "/login") {
        self.path = path
    }
    
    /// See `Middleware`.
    public func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        guard try request.isAuthenticated(A.self) else {
            return request.future(request.redirect(to: path))
        }
        return try next.respond(to: request)
    }
}

extension Authenticatable {
    /// Creates a new `LoginRedirectMiddleware` for self.
    ///
    /// - parameters:
    ///     - path: `String` for path to be redirected to.
    public static func loginRedirectMiddleware(redirect path: String = "/login") -> RedirectToLoginMiddleware<Self> {
        return .init(path: path)
    }
}
