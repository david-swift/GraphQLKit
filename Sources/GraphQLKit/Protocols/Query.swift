//
//  Query.swift
//  GraphQLKit
//
//  Created by david-swift on 08.06.2023.
//

import Foundation

/// A protocol every query conforms to.
/// Normally, you do not use this directly, but add to a class using `@GraphQLQuery`.
public protocol Query: AnyQuery { }
