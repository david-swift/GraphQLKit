//
//  QueryData.swift
//  GraphQLKit
//
//  Created by david-swift on 09.06.2023.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

/// Functions and types for the ``GraphQLQuery`` and ``GraphQLMutation``.
enum QueryData {

    /// An error.
    enum QueryError: CustomStringConvertible, Error {

        /// Can only be applied to structs.
        case onlyApplicableToStructs
        /// The query name is not defined.
        case queryNameRequired
        /// There is no `fields` variable.
        case fieldsVariableRequired

        /// The errors' descriptions.
        var description: String {
            switch self {
            case .onlyApplicableToStructs:
                "GraphQLQuery and GraphQLMutation can only be applied to structs."
            case .queryNameRequired:
                "The static variable \"query\" is required."
            case .fieldsVariableRequired:
                "The variable \"fields\" is required."
            }
        }

    }

    /// Information about a variable.
    struct VariableInformation {

        /// The variable name.
        var name: String
        /// The variable's type.
        var type: String
        /// Whether it is a static variable.
        var isStatic: Bool

    }

    /// Expanding the type's content.
    /// - Parameters:
    ///   - node: The node.
    ///   - declaration: The struct declaration.
    ///   - context: The context.
    /// - Returns: The expansion.
    static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw QueryError.onlyApplicableToStructs
        }
        let members = structDecl.memberBlock.members
        let varDecls = members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
        let bindings = varDecls.compactMap { decl in
            (decl.bindings.first, decl.modifiers?.contains { $0.name.description.contains("static") })
        }
        let elements = bindings.compactMap { element in
            if let info = element.0 {
                return VariableInformation(
                    name: info.pattern.description,
                    type: (info.typeAnnotation?.type.description ?? "String")
                        .trimmingCharacters(in: .whitespacesAndNewlines),
                    isStatic: element.1 ?? false
                )
            }
            return nil
        }
        let string = try getString(elements: elements)
        let get = try getGetFunction(elements: elements)
        return [.init(string), .init(get)]
    }

    /// Get the elements string.
    /// - Parameter elements: The elements.
    /// - Returns: A string.
    private static func getString(
        elements: [VariableInformation]
    ) throws -> VariableDeclSyntax {
        let elements = try filter(elements: elements).1
        var arguments = "("
        for element in elements {
            if element.type.hasSuffix("?") {
                arguments.append(
                    "\\(\(element.name) != nil ? \"\(element.name): \\(\(element.name)!.string), \" : .init())"
                )
            } else {
                arguments.append("\(element.name): \\(\(element.name).string), ")
            }
        }
        if arguments.count == 1 {
            arguments = ""
        } else {
            arguments.append(")")
        }
        return try .init("public var string: String") {
            StmtSyntax(
                stringLiteral: "\"\\(Self.query)\(arguments){ \\(fields.string) }\""
            )
        }
    }

    /// Get the function `get(data:)`.
    /// - Parameter elements: The elements.
    /// - Returns: The function declaration.
    private static func getGetFunction(
        elements: [VariableInformation]
    ) throws -> FunctionDeclSyntax {
        let fields = try filter(elements: elements).0
        return try .init("public func get(data: [String: SwiftyJSON.JSON]) throws") {
            DoStmtSyntax(body: .init {
                StmtSyntax(
                    stringLiteral: """
                let code = try JSONDecoder().decode(
                    \(fields.type).self,
                    from: try data[Self.query]?.rawData() ?? .init()
                )
                """
                )
                StmtSyntax(stringLiteral: "fields.get(value: code)")
            }, catchClauses: try .init {
                try CatchClauseSyntax {
                    StmtSyntax(
                        stringLiteral: """
                        let code = try JSONDecoder().decode(
                            [\(fields.type)].self,
                            from: try data[Self.query]?.rawData() ?? .init()
                        )
                        """
                    )
                    try ForInStmtSyntax("for element in code") {
                        StmtSyntax(stringLiteral: "fields.get(value: element)")
                    }
                }
            })
        }
    }

    /// Filter the elements.
    /// - Parameter elements: The elements.
    /// - Returns: The fields variable and other nonstatic variables.
    private static func filter(elements: [VariableInformation]) throws -> (VariableInformation, [VariableInformation]) {
        var fields = elements.first { !$0.isStatic && $0.name == "fields" }
        let suffix = ".Fields"
        if fields?.type.hasSuffix(suffix) ?? false {
            fields?.type.removeLast(suffix.count)
        }
        if !elements.contains(where: { $0.name == "query" && $0.isStatic == true && $0.type == "String" }) {
            throw QueryError.queryNameRequired
        }
        let elements = elements.filter { !($0.isStatic || $0.name == "fields") }
        if let fields {
            return (fields, elements)
        } else {
            throw QueryError.fieldsVariableRequired
        }
    }

}
