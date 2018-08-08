import Vapor
import Authentication
import Fluent


public protocol AuthUserSupporting: Model, PasswordAuthenticatable, SessionAuthenticatable,
                                    Parameter, Content {
    
    var id: UUID? { get set }
    var username: String { get set }
    var password: String { get set }
    
    static func hashPassword(_ password: String) throws -> String
    
}

extension AuthUserSupporting {
    
    /// See `PasswordAuthenticatable`
    public static var usernameKey: UsernameKey { return \.username }
    public static var passwordKey: PasswordKey { return  \.password }
    
    /// See `AuthUserSupporting`
    public static func hashPassword(_ password: String) throws -> String {
        return try BCrypt.hash(password)
    }
}

public final class AuthUser<D>: AuthUserSupporting where D: Database & QuerySupporting {
    
    public typealias Database = D
    public typealias ID = UUID
    
    /// See `Model`
    public static var idKey: WritableKeyPath<AuthUser<D>, UUID?> {
        return \.id
    }
    
    /// See `Model`
    //public static var name: String { return "authUser" }
    
    public var id: UUID?
    public var username: String
    public var password: String
    
    init(id: UUID? = nil, username: String, password: String) {
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
