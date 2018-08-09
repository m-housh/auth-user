//
//  LoginControllable.swift
//  AuthUser
//
//  Created by Michael Housh on 8/8/18.
//

import Vapor

/// A `RouteCollection` that is responsible for logging in and
/// logging out of users.
public protocol LoginControllable: RouteCollection {
    
    /// The `AuthUserSupporting` object that is used to
    /// authenticate.
    associatedtype User: AuthUserSupporting
    
    /// The `ResponseEncodable` type to return from the login
    /// handler.
    associatedtype LoginReturnType: ResponseEncodable
    
    /// The `ResponseEncodable` type to return from the logout
    /// handler.
    associatedtype LogoutResponseType: ResponseEncodable
    
    /// Middleware that is used for all the routes in this
    /// `RouteCollection`.
    var middleware: [Middleware] { get }
    
    /// The path to register the login route under.
    /// This defaults to '/login'
    var loginPath: [PathComponentsRepresentable] { get }
    
    /// The path to register the logout route under.
    /// This defaults to '/logout'.
    var logoutPath: [PathComponentsRepresentable] { get }
    
    /// The handler for an actual login request.
    func loginHandler(_ request: Request) throws -> LoginReturnType
    
    /// The handler for an actual logout request.
    func logoutHandler(_ request: Request) throws -> LogoutResponseType
    
}

extension LoginControllable {
    
    public var loginPath: [PathComponentsRepresentable] {
        return ["login"]
    }
    
    public var logoutPath: [PathComponentsRepresentable] {
        return ["logout"]
    }
    
    public var middleware: [Middleware] {
        return []
    }
}

extension LoginControllable where LogoutResponseType == Future<HTTPResponseStatus> {
    
    public func logoutHandler(_ request: Request) throws -> Future<HTTPResponseStatus> {
        try request.unauthenticate(User.self)
        return request.future(.ok)
    }

    
}

extension LoginControllable {
    
    /// See `RouteCollection`.
    public func boot(router: Router) throws {
        let group = router.grouped(middleware)
        group.get(loginPath, use: loginHandler)
        group.get(logoutPath, use: logoutHandler)
    }
}
