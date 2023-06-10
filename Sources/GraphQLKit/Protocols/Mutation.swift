//
//  Mutation.swift
//  GraphQLKit
//
//  Created by david-swift on 09.06.2023.
//

import Foundation
import SwiftyJSON

/// A protocol every mutation query conforms to.
/// Normally, you do not use this directly, but add to a class using `@GraphQLMutation`.
public protocol Mutation: AnyQuery { }
