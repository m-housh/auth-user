//
//  LoginController.swift
//  AuthUser
//
//  Created by Michael Housh on 8/4/18.
//

import Vapor
import Authentication


public protocol LoginControllerSupporting: RouteCollection {
    
    associatedtype AuthUser: AuthUserSupporting
    
    var loginRedirectPath: String { get }
    var middleware: [Middleware] { get set }
    
    func loginHandler(_ request: Request) throws -> Future<Response>
    func logoutHandler(_ request: Request) throws -> Future<HTTPResponseStatus>
    
}

extension LoginControllerSupporting {
    
    //public var loginRedirectPath: String { return "/" }
    
    public func loginHandler(_ request: Request) throws -> Future<Response> {
        let response = request.redirect(to: loginRedirectPath)
        return request.future(response)
    }
    
    public func logoutHandler(_ request: Request) throws -> Future<HTTPResponseStatus> {
        try request.unauthenticate(AuthUser.self)
        return request.future(.ok)
    }
    
    public func boot(router: Router) throws {
        let authed = router.grouped(middleware)
        authed.get("login", use: loginHandler)
        authed.get("logout", use: logoutHandler)
    }
    
}

public final class LoginController<A>: LoginControllerSupporting where A: AuthUserSupporting {
    
    public var loginRedirectPath: String
    
    public var middleware: [Middleware]
    
    public typealias AuthUser = A
    
    init(loginRedirect path: String = "/", using middleware: [Middleware] = []) {
        self.loginRedirectPath = path
        self.middleware = middleware
    }
}
