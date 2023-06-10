//
//  GraphQLObject.swift
//  GraphQLKit
//
//  Created by david-swift on 08.06.2023.
//

import Foundation
import RegexBuilder
import SwiftSyntax
import SwiftSyntaxMacros

/// Implementation of the `GraphQLObject` macro, which converts
/// any class into an GraphQL object.
public enum GraphQLObject: MemberMacro, ConformanceMacro {

    /// Errors for the ``GraphQLObject``.
    enum GraphQLObjectError: CustomStringConvertible, Error {

        /// Only applicable to classes.
        case onlyApplicableToClasses
        /// A syntax error occured.
        case syntaxError

        /// A readable description of the error.
        var description: String {
            switch self {
            case .onlyApplicableToClasses:
                return "GraphQLObject can only be applied to classes."
            case .syntaxError:
                return "Check whether you are using the type the macro the right way. If you are, report a bug."
            }
        }

    }

    /// Informatino about a variable.
    private struct VariableInformation {

        /// The capture for the array type regex.
        static let capture = Capture(OneOrMore(.anyNonNewline))
        /// Check whether a type is an array.
        static let arrayType = Regex {
            ChoiceOf {
                Regex {
                    "Array<"
                    capture
                    ">"
                }
                Regex {
                    "["
                    capture
                    "]"
                }
            }
        }

        /// The variable's name.
        var name: String
        /// The variable's type.
        var type: String
        /// Whether the variable has not got fields.
        var isValue: Bool
        /// The variable's arguments.
        var arguments: [(String, String)]

        /// The matches of the array regex if it is an array.
        var matchArray: Substring? {
            let match = type.firstMatch(of: Self.arrayType)?.output
            return match?.1 != nil ? match?.1 : match?.2
        }

        /// The simplest possible parameter using "name: type".
        var simpleParameter: String {
            "\(name): \(type)"
        }

        /// The actual parameter of a variable.
        var parameter: String {
            if isValue {
                return "\(name): ((\(type)) -> Void)?"
            } else if !arguments.isEmpty {
                return "\(name): \(name.capitalized)?"
            } else if let matchArray {
                return "\(name): \(matchArray).Fields?"
            } else {
                return "\(name): \(type).Fields?"
            }
        }

        /// The parameter as a variable definition.
        var variable: String {
            "var \(parameter)"
        }

    }

    /// Expanding the conformance of the type.
    /// - Parameters:
    ///   - node: The node.
    ///   - declaration: The class declaration.
    ///   - context: The context.
    /// - Returns: The expansions (`GraphQLValueType` and `Codable`).
    public static func expansion(
        of node: AttributeSyntax,
        providingConformancesOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [(TypeSyntax, GenericWhereClauseSyntax?)] {
        [(.init(stringLiteral: "GraphQLValueType"), nil), (.init(stringLiteral: "Codable"), nil)]
    }

    /// Expanding the content of the type.
    /// - Parameters:
    ///   - attribute: The node.
    ///   - declaration: The class declaration.
    ///   - context: The context.
    /// - Returns: The expansions.
    public static func expansion(
        of attribute: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            throw GraphQLObjectError.onlyApplicableToClasses
        }
        let members = classDecl.memberBlock.members
        let varDecls = members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
        let bindings = varDecls.compactMap { ($0.bindings.first, isWrapper("Value", in: $0), arguments(variable: $0)) }
        var elements = bindings.compactMap { element in
            if let info = element.0 {
                return VariableInformation(
                    name: info.pattern.description,
                    type: (info.typeAnnotation?.type.description ?? "String")
                        .trimmingCharacters(in: .whitespacesAndNewlines),
                    isValue: element.1,
                    arguments: element.2
                )
            }
            return nil
        }
        let string = try VariableDeclSyntax("public var string: String") {
            StmtSyntax(stringLiteral: getString(elements: elements))
        }
        let initializer = try InitializerDeclSyntax(
            "public init(\(raw: initializer(elements: elements, simple: true)))"
        ) {
            for element in elements {
                StmtSyntax(stringLiteral: "self.\(element.name) = \(element.name)")
            }
        }
        for index in elements.indices {
            elements[index].type.removeLast(1)
        }
        let fields = try fields(elements: elements, type: classDecl.identifier.text)
        return [.init(fields), .init(string), .init(initializer)]
    }

    /// Get the string description of elements.
    /// - Parameter elements: The elements.
    /// - Returns: The description.
    private static func getString(elements: [VariableInformation]) -> String {
        "\"{\(arguments(elements: elements))}\""
    }

    /// Get the fields class.
    /// - Parameters:
    ///   - elements: The elements.
    ///   - type: The class name.
    /// - Returns: The fields class.
    private static func fields(elements: [VariableInformation], type: String) throws -> ClassDeclSyntax {
        try ClassDeclSyntax("public class Fields: GraphQLKit.Fields") {
            for element in elements {
                VariableDeclSyntax(.public, name: .init(stringLiteral: element.variable))
            }
            try InitializerDeclSyntax("public init(\(raw: initializer(elements: elements)))") {
                for element in elements {
                    StmtSyntax(stringLiteral: "self.\(element.name) = \(element.name)")
                }
            }
            try stringDeclaration(elements: elements)
            try getFunction(elements: elements, type: type)
            for element in elements where !element.arguments.isEmpty {
                try getStruct(element: element)
            }
        }
    }

    /// Get the arguments from the elements.
    /// - Parameter elements: The elements.
    /// - Returns: The arguments.
    private static func arguments(elements: [VariableInformation]) -> String {
        var string = ""
        for element in elements {
            if element.type.hasSuffix("?") {
                string.append(
                    "\\(\(element.name) != nil ? \"\(element.name): \\(\(element.name)!.string), \" : .init())"
                )
            } else {
                string.append("\(element.name): \\(\(element.name).string), ")
            }
        }
        return string
    }

    /// Get the `string`'s declaration.
    /// - Parameter elements: The elements.
    /// - Returns: The variable declaration.
    private static func stringDeclaration(elements: [VariableInformation]) throws -> VariableDeclSyntax {
        try VariableDeclSyntax("public var string: String") {
            VariableDeclSyntax(.var, name: .init(stringLiteral: "string: String = .init()"))
            for element in elements {
                if element.isValue {
                    try IfExprSyntax("if \(raw: element.name) != nil") {
                        StmtSyntax(stringLiteral: "string.append(\" \(element.name)\")")
                    }
                } else if element.arguments.isEmpty {
                    try elementQueryInformation(element: element)
                } else {
                    try argumentElementInformation(element: element)
                }

            }
            if let stmt = ReturnStmtSyntax(StmtSyntax(stringLiteral: "return string")) {
                stmt
            } else {
                throw GraphQLObjectError.syntaxError
            }
        }
    }

    /// Get the structure for an element with arguments.
    /// - Parameter element: The element.
    /// - Returns: The structure.
    private static func getStruct(element: VariableInformation) throws -> StructDeclSyntax {
        try StructDeclSyntax("public struct \(raw: element.name.capitalized)") {
            for argument in element.arguments {
                if let decl = VariableDeclSyntax(DeclSyntax(
                    stringLiteral: "public var \(argument.0) = \(argument.1)"
                )) {
                    decl
                } else {
                    throw GraphQLObjectError.syntaxError
                }
            }
            if let decl = VariableDeclSyntax(DeclSyntax(
                stringLiteral: "public var get: (\(element.type)) -> Void"
            )) {
                decl
            } else {
                throw GraphQLObjectError.syntaxError
            }
            try VariableDeclSyntax("public var string: String") {
                StmtSyntax(stringLiteral: """
                "\(arguments(elements: element.arguments.map { element in
                    .init(name: element.0, type: .init(), isValue: false, arguments: [])
                }))"
                """)
            }
        }
    }

    /// Get the declaration of `get(value:)`.
    /// - Parameters:
    ///   - elements: The elements.
    ///   - type: The class name.
    /// - Returns: The function declaration.
    private static func getFunction(elements: [VariableInformation], type: String) throws -> FunctionDeclSyntax {
        try FunctionDeclSyntax("public func get(value: \(raw: type))") {
            for element in elements {
                try IfExprSyntax("if let \(raw: element.name) = value.\(raw: element.name)") {
                    if element.isValue {
                        StmtSyntax(stringLiteral: "self.\(element.name)?(\(element.name))")
                    } else if !element.arguments.isEmpty {
                        StmtSyntax(stringLiteral: "self.\(element.name)?.get(\(element.name))")
                    } else if element.matchArray == nil {
                        StmtSyntax(stringLiteral: "self.\(element.name)?.get(value: \(element.name))")
                    } else {
                        StmtSyntax(stringLiteral: "self.\(element.name)?.get(values: \(element.name))")
                    }
                }
            }
        }
    }

    /// Whether a macro is a wrapper of the variable.
    /// - Parameters:
    ///   - wrapper: The macro's name.
    ///   - variable: The variable.
    /// - Returns: Whether it is a wrapper.
    private static func isWrapper(_ wrapper: String, in variable: VariableDeclSyntax) -> Bool {
        variable.attributes?.first?.description.contains(wrapper) ?? false
    }

    /// Get the arguments of a variable.
    /// - Parameter variable: The variable.
    /// - Returns: The arguments.
    private static func arguments(variable: VariableDeclSyntax) -> [(String, String)] {
        if let dictionary = variable.attributes?.first?
            .as(AttributeSyntax.self)?.argument?
            .as(TupleExprElementListSyntax.self)?.first?.expression
            .as(DictionaryExprSyntax.self)?.content
            .as(DictionaryElementListSyntax.self) {
            return dictionary.map { element in
                var keyExpression = element.keyExpression.description
                keyExpression.removeFirst()
                keyExpression.removeLast()
                return (keyExpression, element.valueExpression.description)
            }
        }
        return []
    }

    /// Get the initializer.
    /// - Parameters:
    ///   - elements: The elements.
    ///   - simple: Whether it is a "simple" or closure initializer.
    /// - Returns: The initializer declaration as a string.
    private static func initializer(elements: [VariableInformation], simple: Bool = false) -> String {
        var string = ""
        for element in elements {
            if element.parameter.hasSuffix("?") {
                string.append("\(simple ? element.simpleParameter : element.parameter) = nil,")
            } else {
                string.append("\(simple ? element.simpleParameter : element.parameter),")
            }
        }
        if !string.isEmpty {
            string.removeLast()
        }
        return string
    }

    /// Get the string information about one variable.
    /// - Parameter element: The variable.
    /// - Returns: The string information.
    private static func elementQueryInformation(element: VariableInformation) throws -> IfExprSyntax {
        try IfExprSyntax("if let \(raw: element.name)") {
            StmtSyntax(stringLiteral: "string.append(\" \(element.name) { \\(\(element.name).string) }\")")
        }
    }

    /// Get the string information about one variable with arguments.
    /// - Parameter element: The variable.
    /// - Returns: The string information.
    private static func argumentElementInformation(element: VariableInformation) throws -> IfExprSyntax {
        try IfExprSyntax("if let \(raw: element.name)") {
            StmtSyntax(stringLiteral: "string.append(\" \(element.name)( \\(\(element.name).string)) \")")
        }
    }
}
