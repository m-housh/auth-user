//
//  RoleCommand.swift
//  AuthUser
//
//  Created by Michael Housh on 8/12/18.
//

import Vapor
import Fluent

public struct RoleCommand<D>: Command where D: QuerySupporting {
   
    public typealias RoleType = Role<D>
   
    public init() { }
    
    public var arguments: [CommandArgument] {
        return [.argument(name: "name")]
    }
    
    public var help: [String] {
        return ["Generates a new Role."]
    }
    
    public var options: [CommandOption] { return [] }

    
    public func run(using context: CommandContext) throws -> EventLoopFuture<Void> {
        let name = try context.argument("name")
        //let dbid = try RoleType.requireDefaultDatabase()
        //let client = try context.container.make(Client.self)
        let url = URL(string: "/user/role/findOrCreate/\(name)")!
        let request = HTTPRequest(method: .GET, url: url, headers: .init())
        let wrappedRequest = Request(http: request, using: context.container)
        let responder = try context.container.make(Responder.self)
        
        
        return try responder.respond(to: wrappedRequest).flatMap { resp in
            return try resp.content.decode(RoleType.self).flatMap { role in
                context.console.print()
                if let id = role.id {
                    context.console.print("Created role: \(role.name), \(id)")
                }
                else {
                    context.console.print("Failed to create role.")
                }
               
                return .done(on: context.container)
            }
        }
        
        /*
        return context.container.withPooledConnection(to: dbid, closure: { conn in
            return try RoleType.findOrCreate(name, on: conn).flatMap { role in
                context.console.print("Created role: \(role.name)")
                _ = role.save(on: conn)
                return .done(on: context.container)
            }
        }) */
    }
}
