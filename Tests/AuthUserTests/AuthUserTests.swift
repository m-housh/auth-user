import XCTest
import Authentication
import Vapor
import FluentSQLite
@testable import AuthUser
@testable import AuthUserTester



final class AuthUserTests: VaporTestCase {
    
    let path = "user"
    
    
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
       // XCTAssertEqual(AuthUser().text, "Hello, World!")
        XCTAssert(true)
    }
    
    ///Remove
    /*
    func testPasswordGetsHashed() {
        
        perform {
            let user = TestAuthUser(username: testUsername, password: testPassword)
            let created = try app.getResponse(
                to: path,
                method: .POST,
                headers: .init(),
                data: user,
                decodeTo: TestAuthUser.self
            )
            
            XCTAssertNotEqual(user.password, created.password)
        }
    }*/
    
    func testLoginRedirects() {
        perform {
            _ = try createUser()
            
            let login = try app.sendRequest(
                to: "login",
                method: .POST,
                headers: basicAuthHeaders
            )
            
            XCTAssertEqual(login.http.status.code, 303)
            
            let location = login.http.headers.firstValue(name: .location)
            XCTAssertEqual(location, "loggedIn")
            
        }
    }
    
    func testLoginControllerWithCustomMiddleware() {
        perform {
            _ = try createUser()
            
            let resp = try app.sendRequest(to: "/custom/login", method: .POST, headers: basicAuthHeaders)
            XCTAssertEqual(resp.http.status.code, 303)
            let location = resp.http.headers.firstValue(name: .location)
            XCTAssertEqual(location, "/")
        }
    }
    
    func testLoginFailsWithNoAuthHeader() {
        perform {            
            XCTAssertThrowsError(
                try app.sendRequest(
                    to: "login",
                    method: .POST
                )
            ) { error in
                XCTAssert(isUnauthorizedError(error))
            }
            //XCTAssertEqual(resp.http.status.code, 401)
        }
    }
    
    
    func testAuthenticatedRoutes() {
        perform {
            
            _ = try createUser()
            
            let resp = try app.getResponse(
                to: "auth",
                headers: basicAuthHeaders,
                decodeTo: TestAuthUser.self
            )
            
            XCTAssertEqual(resp.username, testUsername)
        }
    }
    
    func testLogout() {
        perform {
            _ = try createUser()

            let login = try app.sendRequest(
                to: "auth",
                method: .GET,
                headers: basicAuthHeaders
            )
            
            let cookie = login.http.headers.firstValue(name: .setCookie)!
            var headers = HTTPHeaders()
            headers.add(name: .cookie, value: cookie)
            
            let resp = try app.sendRequest(
                to: "logout",
                method: .GET,
                headers: headers
            )
    
            XCTAssertEqual(resp.http.status.code, 303)
            let location = resp.http.headers.firstValue(name: .location)
            XCTAssertEqual(location, "login")
            
        }
    }
    
    func testLoginRedirectMiddleware() {
        perform {
            _ = try createUser()
            let resp = try app.sendRequest(to: "auth", method: .GET)
            let location = resp.http.headers.firstValue(name: .location)
            XCTAssertEqual(location, "/login")
        }
    }
    
    func testRedirectsAfterLogin() {
        perform {
            _ = try createUser()
            let resp = try app.sendRequest(
                to: "login",
                method: .POST,
                headers: basicAuthHeaders
            )
            XCTAssertEqual(resp.http.status.code, 303)
            let location = resp.http.headers.firstValue(name: .location)
            XCTAssertEqual(location, "loggedIn")
        }
    }
    
    func testAuthOwnerMiddlewareFails() {
        perform {
            _ = try createUser()
            
            let secondUser = try createUser(TestAuthUser(username: "one", password: "test"))
            
            let url = "/user/\(secondUser.id!)"
            
            XCTAssertThrowsError(
                try app.sendRequest(
                    to: url,
                    method: .GET,
                    headers: basicAuthHeaders
                )
            ) { error in
                XCTAssert(isUnauthorizedError(error))
            }
        }
    }
    
    func testAuthOwnerMiddlewareWorks() {
        perform {
            let user = try createUser()
            let url = "/user/\(user.id!)"
            let retrieved = try app.getResponse(
                to: url,
                headers: basicAuthHeaders,
                decodeTo: TestAuthUser.self
            )
            XCTAssertEqual(user.id, retrieved.id)
        }
    }

    func testUniqueOnUsername() {
        perform {
            _ = try createUser()
            XCTAssertThrowsError(try createUser()) { error in
                let err = error as! SQLiteError
                XCTAssertEqual(err.identifier, "constraint")
            }
        }
    }
    
    func testAddRole() {
        perform {
            let user = try createUser()
            let role = try createRole()
            let path = "\(self.path)/\(user.id!)/addRole/\(role.id!)"
            let resp = try app.getResponse(
                to: path,
                decodeTo: TestPublicUser.self
            )
            
            XCTAssertEqual(resp.roles, [roleName])
        }
    }
    
    static var allTests = [
        ("testExample", testExample),
        //("testPasswordGetsHashed", testPasswordGetsHashed),
        ("testLoginRedirects", testLoginRedirects),
        ("testLoginFailsWithNoAuthHeader", testLoginFailsWithNoAuthHeader),
        ("testAuthenticatedRoutes", testAuthenticatedRoutes),
        ("testLogout", testLogout),
        ("testLoginRedirectMiddleware", testLoginRedirectMiddleware),
        ("testRedirectsAfterLogin", testRedirectsAfterLogin),
        ("testAuthOwnerMiddlewareFails", testAuthOwnerMiddlewareFails),
        ("testAuthOwnerMiddlewareFails", testAuthOwnerMiddlewareFails),
        ("testUniqueOnUsername", testUniqueOnUsername),
        ("testLoginControllerWithCustomMiddleware", testLoginControllerWithCustomMiddleware),
    ]
}

/// Helpers
extension AuthUserTests {
    
    /*
    func  createUser(_ user: TestAuthUser? = nil) throws -> TestAuthUser {
        
        let userToCreate = user ?? TestAuthUser(username: testUsername, password: testPassword)
        return try app.getResponse(
            to: path,
            method: .POST,
            headers: .init(),
            data: userToCreate,
            decodeTo: TestAuthUser.self
        )
    }*/
    
    func isUnauthorizedError(_ error: Error) -> Bool {
        guard let err = error as? Abort else {
            return false
        }
        return err.status == .unauthorized
    }
}
