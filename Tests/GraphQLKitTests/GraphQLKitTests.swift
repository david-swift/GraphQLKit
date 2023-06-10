//
//  GraphQLKitTests.swift
//  GraphQLKit
//
//  Created by david-swift on 08.06.2023.
//

import GraphQLKitMacros
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

/// The macros for testing.
let testMacros: [String: Macro.Type] = [
    "GraphQLObject": GraphQLObject.self,
    "Arguments": Arguments.self,
    "Value": Value.self,
    "GraphQLQuery": GraphQLQuery.self
]

// swiftlint:disable empty_first_line
// swiftlint:disable line_length
// swiftlint:disable function_body_length

/// The tests.
final class GraphQLKitTests: XCTestCase {

    /// Test the `GraphQLObject` macro.
    func testGraphQLObject() {
        assertMacroExpansion(
            """
            @GraphQLObject
            public class ActorLocation {
                @Arguments(["lang": "en", "test": 5]) public var city: String? = nil
                public var country: CustomType?
                public var countryCode: [CustomType]?
                @Value public var region: String? = nil
                @Value public var regionCode: String? = nil
            }
            """,
            expandedSource: """

            public class ActorLocation {
                public var city: String? = nil
                    public var country: CustomType?
                    public var countryCode: [CustomType]?
                public var region: String? = nil
                public var regionCode: String? = nil
                public class Fields: GraphQLKit.Fields {
                    public var city: City?
                    public var country: CustomType.Fields?
                    public var countryCode: CustomType.Fields?
                    public var region: ((String) -> Void)?
                    public var regionCode: ((String) -> Void)?
                    public init(city: City? = nil, country: CustomType.Fields? = nil, countryCode: CustomType.Fields? = nil, region: ((String) -> Void)? = nil, regionCode: ((String) -> Void)? = nil) {
                        self.city = city
                        self.country = country
                        self.countryCode = countryCode
                        self.region = region
                        self.regionCode = regionCode
                    }
                    public var string: String {
                        var string: String = .init()
                        if let city {
                            string.append("  city( \\(city.string) ) ")
                        }
                        if let country {
                            string.append("  country { \\(country.string)  }")
                        }
                        if let countryCode {
                            string.append("  countryCode { \\(countryCode.string)  }")
                        }
                        if region != nil {
                            string.append("  region")
                        }
                        if regionCode != nil {
                            string.append("  regionCode")
                        }
                        return string
                    }
                    public func get(value: ActorLocation) {
                        if let city = value.city {
                            self.city?.get(city)
                        }
                        if let country = value.country {
                            self.country?.get(value: country)
                        }
                        if let countryCode = value.countryCode {
                            self.countryCode?.get(values: countryCode)
                        }
                        if let region = value.region {
                            self.region?(region)
                        }
                        if let regionCode = value.regionCode {
                            self.regionCode?(regionCode)
                        }
                    }
                    public struct City {
                        public var lang = "en"
                        public var test = 5
                        public var get: (String) -> Void
                        public var string: String {
                            " lang: \\(lang.string) , test: \\(test.string) , "
                        }
                    }
                }
                public var string: String {
                    " {\\(city != nil ? " city: \\(city!.string) , " : .init()) \\(country != nil ? " country: \\(country!.string) , " : .init()) \\(countryCode != nil ? " countryCode: \\(countryCode!.string) , " : .init()) \\(region != nil ? " region: \\(region!.string) , " : .init()) \\(regionCode != nil ? " regionCode: \\(regionCode!.string) , " : .init()) }"
                }
                public init(city: String? = nil, country: CustomType? = nil, countryCode: [CustomType]? = nil, region: String? = nil, regionCode: String? = nil) {
                    self.city = city
                    self.country = country
                    self.countryCode = countryCode
                    self.region = region
                    self.regionCode = regionCode
                }
            }
            """,
            macros: testMacros
        )
    }

    /// Test the `Arguments` macro.
    func testArguments() {
        assertMacroExpansion(
            """
            struct Foo {
                @Arguments([:]) var bar: String? = nil
            }
            """,
            expandedSource: """
            struct Foo {
                var bar: String? = nil
            }
            """,
            macros: testMacros
        )
    }

    /// Test the `Value` macro.
    func testValue() {
        assertMacroExpansion(
            """
            struct Foo {
                @Value var bar: String? = nil
            }
            """,
            expandedSource: """
            struct Foo {
                var bar: String? = nil
            }
            """,
            macros: testMacros
        )
    }

    /// Test the `GraphQLQuery` macro.
    func testGraphQLQuery() {
        assertMacroExpansion(
            """
            @GraphQLQuery
            public struct Foo {
                public static var query: String {
                    "foo"
                }
                public var bar: String
                public var foo: Bool?
                public var fields: FooData.Fields
            }
            """,
            expandedSource: """

            public struct Foo {
                public static var query: String {
                    "foo"
                }
                public var bar: String
                public var foo: Bool?
                public var fields: FooData.Fields
                public var string: String {
                    " \\(Self.query) (bar: \\(bar.string) , \\(foo != nil ? " foo: \\(foo!.string) , " : .init()) ){ \\(fields.string)  }"
                }
                public func get(data: [String: SwiftyJSON.JSON]) throws {
                    do {
                        let code = try JSONDecoder().decode(FooData.self, from: try data[Self.query]?.rawData() ?? .init())
                        fields.get(value: code)
                    } catch {
                        let code = try JSONDecoder().decode([FooData].self, from: try data[Self.query]?.rawData() ?? .init())
                        for element in code {
                            fields.get(value: element)
                        }
                    }
                }
            }
            """,
            macros: testMacros
        )
    }

}

// swiftlint:enable empty_first_line
// swiftlint:enable line_length
// swiftlint:enable function_body_length
