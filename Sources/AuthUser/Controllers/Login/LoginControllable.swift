//
//  LoginControllable.swift
//  AuthUser
//
//  Created by Michael Housh on 8/8/18.
//

import Vapor

public protocol LoginControllable: RouteCollection {
    
    associatedtype User: AuthUserSupporting
    associatedtype LoginReturnType: ResponseEncodable
    associatedtype LogoutResponseType: ResponseEncodable
    
    var middleware: [Middleware] { get }
    var loginPath: [PathComponentsRepresentable] { get }
    var logoutPath: [PathComponentsRepresentable] { get }
    
    func loginHandler(_ request: Request) throws -> LoginReturnType
    func logoutHandler(_ request: Request) throws -> LogoutResponseType
    
}

extension LoginControllable {
    
    public var loginPath: [PathComponentsRepresentable] {
        return ["login"]
    }
    
    public var logoutPath: [PathComponentsRepresentable] {
        return ["logout"]
    }
}

extension LoginControllable where LogoutResponseType == Future<HTTPResponseStatus> {
    
    public func logoutHandler(_ request: Request) throws -> Future<HTTPResponseStatus> {
        try request.unauthenticate(User.self)
        return request.future(.ok)
    }

    
}

/*
extension LoginControllable where User: ResponseEncodable, LoginReturnType == Future<User> {
    
    public func loginHandler(_ request: Request) throws -> Future<User> {
        let user = try request.requireAuthenticated(User.self)
        return request.future(user)
    }
}
*/

extension LoginControllable {
    
    /// See `RouteCollection`.
    public func boot(router: Router) throws {
        let group = router.grouped(middleware)
        group.get(loginPath, use: loginHandler)
        group.get(logoutPath, use: logoutHandler)
    }
}
