//
//  WrapperError.swift
//  GraphQLKit
//
//  Created by david-swift on 08.06.2023.
//

/// Errors for the wrapper macros.
public enum WrapperError: CustomStringConvertible, Error {

    /// Only applicable to variable declarations.
    case hasToBeVariable
    /// Only applicable to variable declarations with default values.
    case defaultValueRequired

    /// A textual representation.
    public var description: String {
        switch self {
        case .hasToBeVariable:
            "This macro can only be applied to variable declarations."
        case .defaultValueRequired:
            "This macro can only be applied to variable declarations providing a default value."
        }
    }

}
