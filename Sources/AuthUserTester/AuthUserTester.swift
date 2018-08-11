//
//  AuthUserTester.swift
//  AuthUserTester
//
//  Created by Michael Housh on 8/10/18.
//

import Foundation

import Fluent
import AuthUser
import Vapor
import Authentication
import XCTest

public final class AuthUserTester<Database> where Database: MigrationSupporting & QuerySupporting {
    
    //fileprivate typealias D = Database
    public let app: Application
    public let path: String
    public let expectedDeleteCode: UInt
    
    public var users: [AuthUser<Database>] {
        return [
            AuthUser<Database>(username: "foo", password: "bar"),
            AuthUser<Database>(username: "bar", password: "foo"),
            AuthUser<Database>(username: "qux", password: "quack")
        ]
    }
    
    init(app: Application, path: String = "user", deleteCode: UInt = 200) {
        self.app = app
        self.path = path
        self.expectedDeleteCode = deleteCode
    }
    
    private func create(_ user: AuthUser<Database>) throws -> AuthUser<Database> {
        return try app.getResponse(
            to: path,
            method: .POST,
            headers: .init(),
            data: user,
            decodeTo: AuthUser<Database>.self
        )
    }
    
    private func createAll() throws -> [AuthUser<Database>] {
        var users: [AuthUser<Database>] = []
        for u in self.users {
            users.append(try create(u))
        }
        return users
    }
    
    private func authHeaders(_ user: AuthUser<Database>) throws -> HTTPHeaders {
        let user = self.users.first {
            $0.username == user.username }!
        
        var headers = HTTPHeaders()
        headers.basicAuthorization = BasicAuthorization(username: user.username, password: user.password)
        return headers
    }
    
    public func createUsers() throws {
        for user in users {
            let resp = try create(user)
            XCTAssertNotNil(resp.id)
        }
    }
    
    public func getByID() throws {
        let users = try createAll()
        
        XCTAssertEqual(users.count, self.users.count)
        
        for user in users {
            let resp = try app.getResponse(
                to: "\(path)/\(user.id!)",
                headers: try authHeaders(user),
                decodeTo: AuthUser<Database>.self
            )
            XCTAssertEqual(resp.id, user.id)
        }
    }
    
    public func getAll() throws {
        let users = try createAll()
        
        let resp = try app.getResponse(to: path, decodeTo: [AuthUser<Database>].self)
        XCTAssertEqual(users.count, resp.count)
    }
    
    public func delete() throws {
        let users = try createAll()
        for user in users {
            let resp = try app.sendRequest(
                to: "\(path)/\(user.id!)",
                method: .DELETE,
                headers: try authHeaders(user)
            )
            XCTAssertEqual(resp.http.status.code, expectedDeleteCode)
        }
    }
    
    public func update() throws {
        let users = try createAll()
        
        for (i, user) in users.enumerated() {
            let username = "\(user.username)-\(i)"
            let headers = try authHeaders(user)
            user.username = username
            let resp = try app.getResponse(
                to: "\(path)/\(user.id!)",
                method: .PUT,
                headers: headers,
                data: user,
                decodeTo: AuthUser<Database>.self
            )
            
            XCTAssertEqual(resp.username, username)
        }
    }
}
