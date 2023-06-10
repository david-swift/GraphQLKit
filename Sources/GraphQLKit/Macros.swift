//
//  Macros.swift
//  GraphQLKit
//
//  Created by david-swift on 08.06.2023.
//

/// A macro that converts any class into a GraphQL object.
@attached(conformance)
@attached(member, names: named(Fields), named(string), named(init))
public macro GraphQLObject() = #externalMacro(module: "GraphQLKitMacros", type: "GraphQLObject")

/// A macro that converts a class into a GraphQL mutation.
@attached(conformance)
@attached(member, names: named(string), named(init), arbitrary)
public macro GraphQLMutation() = #externalMacro(module: "GraphQLKitMacros", type: "GraphQLMutation")

/// A macro that converts a class into a GraphQL query.
@attached(conformance)
@attached(member, names: named(string), named(get))
public macro GraphQLQuery() = #externalMacro(module: "GraphQLKitMacros", type: "GraphQLQuery")

/// Add arguments to a value type.
@attached(accessor)
public macro Arguments(_ args: [String: any GraphQLValueType]) = #externalMacro(
    module: "GraphQLKitMacros",
    type: "Arguments"
)

/// Mark a type that does not contain fields.
@attached(accessor)
public macro Value() = #externalMacro(module: "GraphQLKitMacros", type: "Value")
