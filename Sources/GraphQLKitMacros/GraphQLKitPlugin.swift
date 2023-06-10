//
//  GraphQLKitPlugin.swift
//  GraphQLKit
//
//  Created by david-swift on 08.06.2023.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// The available macros.
@main
struct GraphQLKitPlugin: CompilerPlugin {

    /// The available macros.
    let providingMacros: [Macro.Type] = [
        GraphQLObject.self,
        GraphQLQuery.self,
        GraphQLMutation.self,
        Arguments.self,
        Value.self
    ]

}
