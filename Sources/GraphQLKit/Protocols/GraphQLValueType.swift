//
//  GraphQLValueType.swift
//  GraphQLKit
//
//  Created by david-swift on 08.06.2023.
//

import Foundation

/// The protocol a type has to conform to to be usable with `@Value` or as a `@Arguments` argument.
/// Types defined using the `@GraphQLObject` macro automatically conform to this protocol.
/// `Array`, `Bool`, `Double`, `Int`,  `String` and `URL` conform to this protocol.
public protocol GraphQLValueType {

    /// A textual representation for GraphQL queries and mutations.
    var string: String { get }

}
