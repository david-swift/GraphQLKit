//
//  Double.swift
//  GraphQLKit
//
//  Created by david-swift on 08.06.2023.
//

import Foundation

extension Double: GraphQLValueType {

    /// Description for GraphQL.
    public var string: String { description }

}
