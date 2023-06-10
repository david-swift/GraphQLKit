//
//  AnyQuery.swift
//  GraphQLKit
//
//  Created by david-swift on 09.06.2023.
//

import Foundation
import SwiftyJSON

/// The requirements of any query (either a query or mutation).
/// Normally, you should not need to call that protocol directly in your project.
public protocol AnyQuery {

    /// The type of the fields.
    associatedtype FieldsType: Fields

    /// The query's name.
    static var query: String { get }

    /// A textual description of the query.
    var string: String { get }
    /// The fields.
    var fields: FieldsType { get }

    /// Get the information by providing JSON data.
    /// - Parameter data: An array containing the JSON data.
    func `get`(data: [String: JSON]) throws

}
