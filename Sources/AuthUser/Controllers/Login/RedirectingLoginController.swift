//
//  RedirectingLoginController.swift
//  AuthUser
//
//  Created by Michael Housh on 8/8/18.
//

import Vapor
import Authentication


public protocol RedirectingLoginControllable: LoginControllable {
    
    var loginRedirectPath: String { get }
}

extension RedirectingLoginControllable where LoginReturnType == Response {
    
    public func loginHandler(_ request: Request) throws -> Response {
        _ = try request.requireAuthenticated(User.self)
        return request.redirect(to: loginRedirectPath)
    }
    
}

public final class RedirectingLoginController<A>: RedirectingLoginControllable where A: AuthUserSupporting, A.ResolvedParameter == Future<A> {
    
    public typealias User = A
    public typealias LoginReturnType = Response
    public typealias LogoutResponseType = Future<HTTPResponseStatus>
    
    public var loginRedirectPath: String = "/"
    public var middleware: [Middleware] = []
    
    public var defaultMiddleware: [AuthMiddlewareType] {
        return [.session, .basic, .guardAuth]
    }
    
    init(redirectingTo path: String? = nil, using middleware: AuthMiddlewareType...) {
        
        if let path = path {
            self.loginRedirectPath = path
        }
        
        if middleware.count == 0 {
            self.middleware = defaultMiddleware.authMiddleware(User.self)
        } else {
            self.middleware = middleware.authMiddleware(User.self)
        }
    }


}
