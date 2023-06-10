//
//  Int.swift
//  GraphQLKit
//
//  Created by david-swift on 08.06.2023.
//

import Foundation

extension Int: GraphQLValueType {

    /// A description for GraphQL.
    public var string: String { description }

}
