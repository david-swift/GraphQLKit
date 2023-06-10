//
//  Fields.swift
//  GraphQLKit
//
//  Created by david-swift on 08.06.2023.
//

import Foundation

/// A protocol defining the content of fields.
/// You normally should not use that protocol directly in your code,
/// but add a fields type to a class using the `@GraphQLKitObject` macro.
public protocol Fields {

    /// The type that the fields describe.
    associatedtype Value

    /// A textual description of the choices.
    var string: String { get }

    /// Call the fields using a value.
    /// - Parameter value: The value.
    func `get`(value: Value)

}

extension Fields {

    /// Get multiple values with a field.
    /// - Parameter values: The values.
    public func get(values: [Value]) {
        for value in values {
            self.get(value: value)
        }
    }

}
