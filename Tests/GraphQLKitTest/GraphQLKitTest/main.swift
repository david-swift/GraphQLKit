//
//  main.swift
//  GraphQLKit
//
//  Created by david-swift on 08.06.2023.
//
//  swiftlint:disable trailing_closure
//  swiftlint:disable force_unwrapping

import Foundation
import GraphQLKit
import GraphQLKitMacros
import SwiftyJSON

/// The dispatch group.
let group = DispatchGroup()

group.enter()

/// A query for testing the countries API.
let continentQuery = ContinentQuery(code: "NA", fields: .init(
    countries: .init(
        code: { print($0) },
        name: .init(lang: "de") { print($0) }
    )
))
/// A query for testing the countries API.
let continentsQuery = Continents(fields: .init(
    countries: .init(
        continent: .init(
            name: { print($0) }
        ),
        emoji: { print($0) },
        name: .init(lang: "en") { print($0) }
    )
))

Task {
    do {
        try await GraphQL(url: "https://countries.trevorblades.com/graphql").query {
            continentQuery
            continentsQuery
        } getRequest: { url, data in
            URLRequest(url: .init(string: "\(url.description)?query=\(data)")!)
        }
        var id = ""
        var name = ""
        try await GraphQL(url: "https://graphqlzero.almansi.me/api").query {
            UserQuery(id: "1", fields: .init(
                id: { id = $0 },
                name: { name = $0 }
            ))
        }
        print("ID: \(id), NAME: \(name)")
        try await GraphQL(url: "https://graphqlzero.almansi.me/api").mutation {
            CreateAlbum(input: .init(
                title: "Hi",
                userId: "1"
            ), fields: .init(
                id: { print($0) },
                title: { print($0) }
            ))
        }
    } catch {
        print(error)
    }
    group.leave()
}

print(UserQuery(id: "1", fields: .init(
    id: { print($0) },
    name: { print($0) }
)).string)

group.wait()

// swiftlint:enable trailing_closure
// swiftlint:enable force_unwrapping
