//
//  RoleSupporting.swift
//  AuthUser
//
//  Created by Michael Housh on 8/11/18.
//

import Vapor
import Fluent

public protocol RoleSupporting: Model, Content, Parameter {
    
    var id: Role<Database>.ID? { get }
    var name: String { get }
}
