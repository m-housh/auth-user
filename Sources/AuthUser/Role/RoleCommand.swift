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
        let client = try context.container.make(Client.self)
        let url = URL(string: "/user/role/findOrCreate/\(name)")!
        
        return client.get(url).flatMap { resp in
            return try resp.content.decode(RoleType.self).flatMap { role in
                context.console.print()
                context.console.print("Created role: \(role.name), \(role.id)")
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
