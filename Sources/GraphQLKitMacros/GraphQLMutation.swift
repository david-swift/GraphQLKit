//
//  GraphQLMutation.swift
//  GraphQLKit
//
//  Created by david-swift on 09.06.2023.
//
//  swiftlint:disable string_literals

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

/// The `@GraphQLMutation` macro.
public enum GraphQLMutation: MemberMacro, ConformanceMacro {

    /// Expanding the type's content.
    /// - Parameters:
    ///   - node: The node.
    ///   - declaration: The class declaration.
    ///   - context: The context.
    /// - Returns: The type's content.
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        try QueryData.expansion(of: node, providingMembersOf: declaration, in: context)
    }

    /// Expanding the types conformances.
    /// - Parameters:
    ///   - node: The node.
    ///   - declaration: The class declaration.
    ///   - context: The context.
    /// - Returns: The conformance to the `Mutation` protocol.
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingConformancesOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [(SwiftSyntax.TypeSyntax, SwiftSyntax.GenericWhereClauseSyntax?)] {
        [(.init(stringLiteral: "Mutation"), nil)]
    }

}

// swiftlint:enable string_literals
