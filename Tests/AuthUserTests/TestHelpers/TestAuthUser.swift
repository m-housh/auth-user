//
//  SQLiteAuthUser.swift
//  AuthUser
//
//  Created by Michael Housh on 8/3/18.
//

import FluentSQLite
import Vapor

@testable import AuthUser

typealias TestAuthUser = AuthUser<SQLiteDatabase>
typealias TestLoginController = RedirectingLoginController<TestAuthUser>
typealias TestAuthUserController = AuthUserController<SQLiteDatabase>
typealias TestRole = Role<SQLiteDatabase>
typealias TestRoleController = RoleController<SQLiteDatabase>
typealias TestUserRole = UserRole<SQLiteDatabase>
typealias TestPublicUser = PublicUser<SQLiteDatabase>
typealias TestRoleCommand = RoleCommand<SQLiteDatabase>

/// Helper used in a route to test users are logged in.
struct LoggedInContext: Content {
    
    let message: String
    
    init(for user: TestAuthUser) {
        self.message = "\(user.username) logged in!"
    }
}
