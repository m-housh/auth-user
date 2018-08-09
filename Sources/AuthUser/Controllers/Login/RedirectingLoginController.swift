//
//  RedirectingLoginController.swift
//  AuthUser
//
//  Created by Michael Housh on 8/8/18.
//

import Vapor
import Authentication

/// A `RouteCollection` that is responsible for logging in and
/// logging out users.  Redirecting users to a particular endpoint.
/// once a successful login has occured.
public protocol RedirectingLoginControllable: LoginControllable {
    
    /// The endpoint to redirect to once a successful login has
    /// occured.
    var loginRedirectPath: String { get }
    
    /// The endpoint to redirect to once a user logs out.
    var logoutRedirectPath: String { get }
}

extension RedirectingLoginControllable where LoginReturnType == Response, LogoutReturnType == Response {
    
    public var logoutRedirectPath: String {
        return loginPath
    }
    
    /// See `LoginControllable`.
    public func loginHandler(_ request: Request) throws -> Response {
        _ = try request.requireAuthenticated(User.self)
        return request.redirect(to: loginRedirectPath)
    }
    
    public func logoutHandler(_ request: Request) throws -> Response {
        try request.unauthenticate(User.self)
        return request.redirect(to: logoutRedirectPath)
    }
    
}

extension Array where Element == AuthMiddlewareType {
    
    fileprivate static func `default`() -> [AuthMiddlewareType] {
        return [.session, .basic, .guardAuth]
    }
    
}

public final class RedirectingLoginController<A>: RedirectingLoginControllable where A: AuthUserSupporting, A.ResolvedParameter == Future<A> {
    
    public typealias User = A
    public typealias LoginReturnType = Response
    public typealias LogoutReturnType = Response
    
    public var loginRedirectPath: String = "/"
    public var middleware: [Middleware] = []
    
    init(redirectingTo path: String = "/", using middleware: AuthMiddlewareType...) {
        
        self.loginRedirectPath = path
        
        var middleware = middleware
        
        if middleware.count == 0 {
            middleware = .default()
        }
        
        self.middleware = middleware.authMiddleware(User.self)
    }


}
