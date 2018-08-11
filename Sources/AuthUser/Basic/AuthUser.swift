import Vapor
import Fluent
import Authentication

public final class AuthUser<D>: AuthUserSupporting
                    where D: Database & QuerySupporting {
    
    public typealias Database = D
    public typealias ID = UUID
    
    /// See `Model`
    public static var idKey: WritableKeyPath<AuthUser<D>, UUID?> {
        return \.id
    }
    
    public var id: UUID?
    public var username: String
    public var password: String
    
    public init(id: UUID? = nil, username: String, password: String) {
        self.id = id
        self.username = username
        self.password = password
    }
}

/// See `AuthUserSupporting`.
/// Allows our user to be used as a parameter and return value in routes.
extension AuthUser: Parameter, Content { }


extension AuthUser: Migration, AnyMigration where D: SchemaSupporting & MigrationSupporting {
    
    /// add's unique constraint to the username field.
    public static func prepare(on conn: D.Connection) -> Future<Void> {
        return D.create(AuthUser<D>.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.username)
            builder.field(for: \.password)
            builder.unique(on: \.username)
        }
    }
    
 }
