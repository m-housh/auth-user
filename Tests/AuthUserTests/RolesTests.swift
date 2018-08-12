//
//  RolesTests.swift
//  AuthUserTests
//
//  Created by Michael Housh on 8/11/18.
//

import XCTest

@testable import AuthUser


final class RolesTests: VaporTestCase {
    
    let path = "/user/role"
    
    func testCreate() {
        perform {
            let role = try createRole()
            XCTAssertEqual(role.name, roleName)
            XCTAssertNotNil(role.id)
        }
    }
    
    func testGet() {
        perform {
            _ = try createRole()
            let resp = try app.getResponse(to: path, decodeTo: [TestRole].self)
            XCTAssertEqual(resp.count, 1)
            XCTAssertEqual(resp[0].name, roleName)
        }
    }
    
    func testAddUserToRole() {
        
        perform {
            let role = try createRole()
            let user = try createUser()
            var path = "\(self.path)/\(role.id!)"
            
            let resp = try app.getResponse(
                to: path,
                method: .POST,
                headers: .init(),
                data: user,
                decodeTo: TestRole.self
            )
            
            XCTAssertEqual(resp.id!, role.id!)
            
            path = "/user/\(user.id!)/public"
            
            let userResp = try app.getResponse(
                to: path,
                method: .GET,
                headers: .init(),
                decodeTo: TestPublicUser.self
            )
            
            XCTAssertEqual(userResp.id!, user.id!)
            XCTAssertEqual(userResp.username, user.username)
            XCTAssertEqual(userResp.roles, ["user"])
            
        }
    }
    
    func testFindOrCreate() {
        perform {
            let path = "\(self.path)/findOrCreate/admin"
            let admin = try app.getResponse(
                to: path,
                decodeTo: TestRole.self
            )
            XCTAssertEqual(admin.name, "admin")
            XCTAssertNotNil(admin.id)
            
            let resp = try app.getResponse(
                to: path,
                decodeTo: TestRole.self
            )
            XCTAssertNotNil(resp.id)
            XCTAssertEqual(resp.id, admin.id)
            
            
        }
    }
    
    func testRoleCommand() {
        perform {
            let args = ["vapor", "role", "commandRole"]
            try makeApplication(args).asyncRun().wait()
            XCTAssert(true)
        }
    }
    
}
