//
//  Countries.swift
//  GraphQLKit
//
//  Created by david-swift on 09.06.2023.
//
//  swiftlint:disable missing_docs
//  swiftlint:disable redundant_optional_initialization
//  swiftlint:disable discouraged_optional_collection
//  swiftlint:disable discouraged_optional_boolean
//  swiftlint:disable identifier_name

import Foundation
import GraphQLKit
import GraphQLKitMacros
import SwiftyJSON

/*
All of the objects and queries for the countries API:
https://countries.trevorblades.com
*/

@GraphQLObject
final class Continent {

    @Value var code: String? = nil
    var countries: [Country]?
    @Value var name: String? = nil

}

@GraphQLObject
final class Country {

    @Value var awsRegion: String? = nil
    @Value var capital: String? = nil
    @Value var code: String? = nil
    var continent: Continent?
    @Value var currencies: [String]? = nil
    @Value var currency: String? = nil
    @Value var emoji: String? = nil
    @Value var emojiU: String? = nil
    var languages: [Language]?
    @Arguments(["lang": "en"])
    @Value var name: String? = nil
    @Value var native: String? = nil
    @Value var phone: String? = nil
    @Value var phones: [String]? = nil
    var states: [State]?
    var subdivisions: [Subdivision]?

}

@GraphQLObject
final class Language {

    @Value var code: String? = nil
    @Value var name: String? = nil
    @Value var native: String? = nil
    @Value var rtl: Bool? = nil

}

@GraphQLObject
final class State {

    @Value var code: String? = nil
    var country: Country?
    @Value var name: String? = nil

}

@GraphQLObject
final class Subdivision {

    @Value var code: String? = nil
    @Value var emoji: String? = nil
    @Value var name: String? = nil

}

@GraphQLObject
final class ContinentFilterInput {

    var code: StringQueryOperatorInput?

}

@GraphQLObject
final class CountryFilterInput {

    var code: StringQueryOperatorInput?
    var continent: StringQueryOperatorInput?
    var currency: StringQueryOperatorInput?

}

@GraphQLObject
final class LanguageFilterInput {

    var code: StringQueryOperatorInput?

}

@GraphQLObject
final class StringQueryOperatorInput {

    @Value var eq: String? = nil
    @Value var `in`: [String]? = nil
    @Value var ne: String? = nil
    @Value var nin: [String]? = nil
    @Value var regex: String? = nil

}

@GraphQLQuery
struct ContinentQuery {

    static var query: String {
        "continent"
    }
    var code: String
    var fields: Continent.Fields

}

@GraphQLQuery
struct Continents {

    static var query: String {
        "continents"
    }
    var filter: ContinentFilterInput = .init()
    var fields: Continent.Fields

}

@GraphQLQuery
struct Countries {

    static var query: String {
        "countries"
    }
    var filter: CountryFilterInput = .init()
    var fields: Country.Fields

}

@GraphQLQuery
struct CountryQuery {

    static var query: String {
        "country"
    }
    var code: String
    var fields: Country.Fields

}

@GraphQLQuery
struct LanguageQuery {

    static var query: String {
        "language"
    }
    var code: String
    var fields: Language.Fields

}

@GraphQLQuery
struct Languages {

    static var query: String {
        "languages"
    }
    var filter: LanguageFilterInput = .init()
    var fields: Language.Fields

}

// swiftlint:enable missing_docs
// swiftlint:enable redundant_optional_initialization
// swiftlint:enable discouraged_optional_collection
// swiftlint:enable discouraged_optional_boolean
// swiftlint:enable identifier_name
