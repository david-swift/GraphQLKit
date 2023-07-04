//
//  VariableInformation.swift
//  GraphQLKit
//
//  Created by david-swift on 02.07.2023.
//

import Foundation
import RegexBuilder

/// Information about a variable.
public struct VariableInformation {

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
    /// The variable's arguments (name, default value).
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
        "\(name): \(parameterType)?"
    }

    /// The type of a parameter of the variable.
    var parameterType: String {
        if isValue && arguments.isEmpty {
            return "((\(type)) -> Void)"
        } else if !arguments.isEmpty {
            return "\(name.capitalized)Arguments"
        } else if let matchArray {
            return "\(matchArray).Fields"
        } else {
            return "\(type).Fields"
        }
    }

    /// The type of the get variable in the arguments structure.
    var parameterValueType: String {
        if !arguments.isEmpty && isValue {
            return "((\(type)) -> Void)"
        } else if !isValue, let matchArray {
            return "\(matchArray).Fields"
        } else {
            return "\(type).Fields"
        }
    }

    /// The parameter for the arguments initializer.
    var initializerValueType: String {
        if !arguments.isEmpty && isValue {
            return "@escaping \(parameterValueType)"
        } else {
            return parameterValueType
        }
    }

    /// The parameter as a variable definition.
    var variable: String {
        "var \(parameter)"
    }

}
