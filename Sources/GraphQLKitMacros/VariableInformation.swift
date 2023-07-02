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
        if isValue && arguments.isEmpty {
            return "\(name): ((\(type)) -> Void)?"
        } else if !arguments.isEmpty {
            return "\(name): \(name.capitalized)Arguments?"
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
