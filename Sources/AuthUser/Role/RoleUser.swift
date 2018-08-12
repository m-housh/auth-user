//
//  RoleUser.swift
//  AuthUser
//
//  Created by Michael Housh on 8/11/18.
//

public protocol RoleUser: AuthUserSupporting {
    
    associatedtype RoleType: RoleSupporting
}
