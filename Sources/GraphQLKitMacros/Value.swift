//
//  Value.swift
//  GraphQLKit
//
//  Created by david-swift on 08.06.2023.
//

import SwiftSyntax
import SwiftSyntaxMacros

/// The `@Value` macro.
public enum Value: AccessorMacro {

    /// The expansion (has no effect as this macro is only used for marking values for the GraphQL object).
    /// - Parameters:
    ///   - node: The node.
    ///   - declaration: The declaration.
    ///   - context: The context.
    /// - Returns: An empty array.
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let declaration = declaration.as(VariableDeclSyntax.self) else {
            throw WrapperError.hasToBeVariable
        }
        guard declaration.bindings.first?.initializer != nil else {
            throw WrapperError.defaultValueRequired
        }
        return []
    }

}
