//
//  GraphQLObject.swift
//  GraphQLKit
//
//  Created by david-swift on 08.06.2023.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

/// Implementation of the `GraphQLObject` macro, which converts
/// any class into an GraphQL object.
public enum GraphQLObject: MemberMacro, ConformanceMacro {

    /// Errors for the ``GraphQLObject``.
    enum GraphQLObjectError: CustomStringConvertible, Error {

        /// An error.
        case onlyApplicableToClasses, syntaxError

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
    /// - Parameters:
    ///   - elements: The elements.
    ///   - brackets: Whether there are curly brackets around the arguments.
    /// - Returns: The description.
    private static func getString(elements: [VariableInformation], brackets: Bool = true) -> String {
        if brackets {
            return "\"{\(arguments(elements: elements))}\""
        } else {
            return "\"\(arguments(elements: elements))\""
        }
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
            try stringDeclaration(elements: elements); try getFunction(elements: elements, type: type)
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
                if element.isValue && element.arguments.isEmpty {
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
        try StructDeclSyntax("public struct \(raw: element.name.capitalized)Arguments") {
            for argument in element.arguments {
                if let decl = VariableDeclSyntax(DeclSyntax(
                    stringLiteral: "public var \(argument.0): \(argument.1)?"
                )) {
                    decl
                } else {
                    throw GraphQLObjectError.syntaxError
                }
            }
            if element.isValue {
                if let decl = VariableDeclSyntax(DeclSyntax(
                    stringLiteral: "public var get: (\(element.type)) -> Void"
                )) {
                    decl
                } else {
                    throw GraphQLObjectError.syntaxError
                }
            } else {
                if let decl = VariableDeclSyntax(DeclSyntax(
                    stringLiteral: "public var get: \(element.parameterValueType)"
                )) {
                    decl
                } else {
                    throw GraphQLObjectError.syntaxError
                }
            }
            try getStructString(element: element); try getStructInitializer(element: element)
        }
    }

    /// Get the initializer for an arguments structure.
    /// - Parameter element: The variable with the arguments.
    /// - Returns: The initializer.
    private static func getStructInitializer(element: VariableInformation) throws -> InitializerDeclSyntax {
        var initializer = ""
        for argument in element.arguments {
            initializer.append("\(argument.0): \(argument.1)? = nil, ")
        }
        initializer.append("get: \(element.initializerValueType)")
        return try InitializerDeclSyntax("public init(\(raw: initializer))") {
            for argument in element.arguments {
                StmtSyntax("self.\(raw: argument.0) = \(raw: argument.0)")
            }
            StmtSyntax("self.get = get")
        }
    }

    /// Get the string variable in a structure for a variable with arguments.
    /// - Parameter element: The variable with arguments.
    /// - Returns: The variable declaration.
    private static func getStructString(element: VariableInformation) throws -> VariableDeclSyntax {
        try .init("public var string: String") {
            let elements: [VariableInformation] = element.arguments.map { key, value in
                    .init(name: key, type: "\(value)?", isValue: true, arguments: [])
            }
            StmtSyntax(stringLiteral: getString(elements: elements, brackets: false))
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
                    if element.isValue && element.arguments.isEmpty {
                        StmtSyntax(stringLiteral: "self.\(element.name)?(\(element.name))")
                    } else if !element.arguments.isEmpty && element.isValue {
                        StmtSyntax(stringLiteral: "self.\(element.name)?.get(\(element.name))")
                    } else if !element.arguments.isEmpty && element.matchArray != nil {
                        StmtSyntax(stringLiteral: "self.\(element.name)?.get.get(values: \(element.name))")
                    } else if !element.arguments.isEmpty && !element.isValue {
                        StmtSyntax(stringLiteral: "self.\(element.name)?.get.get(value: \(element.name))")
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
        guard let attributes = variable.attributes else {
            return false
        }
        for attribute in attributes where attribute.description.contains(wrapper) {
            return true
        }
        return false
    }

    /// Get the arguments of a variable.
    /// - Parameter variable: The variable.
    /// - Returns: The arguments.
    private static func arguments(variable: VariableDeclSyntax) -> [(String, String)] {
        guard let attributes = variable.attributes else {
            return []
        }
        for attribute in attributes {
            guard let tupleElementList = attribute
                .as(AttributeSyntax.self)?.argument?
                .as(TupleExprElementListSyntax.self) else { continue }
            for tupleElement in tupleElementList {
                if let dictionary = tupleElement.expression
                    .as(DictionaryExprSyntax.self)?.content
                    .as(DictionaryElementListSyntax.self) {
                    return dictionary.map { element in
                        var keyExpression = element.keyExpression.description
                        keyExpression.removeFirst()
                        keyExpression.removeLast()
                        var type = element.valueExpression.description
                        let selfLength = 5
                        if type.count > selfLength {
                            type.removeLast(selfLength)
                        }
                        return (keyExpression, type)
                    }
                }
            }
        }; return []
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
        if !string.isEmpty { string.removeLast() }
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
            let firstPart = "string.append(\" \(element.name)( \\(\(element.name).string)) "
            if element.isValue {
                StmtSyntax(stringLiteral: "\(firstPart)\")")
            } else {
                StmtSyntax(stringLiteral: "\(firstPart){ \\(\(element.name).get.string) }\")")
            }
        }
    }
}
