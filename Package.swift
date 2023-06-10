// swift-tools-version: 5.9
//
//  Package.swift
//  GraphQLKit
//
//  Created by david-swift on 08.06.23.
//

import CompilerPluginSupport
import PackageDescription

/// The GraphQLKit package.
let package = Package(
    name: "GraphQLKit",
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "GraphQLKit",
            targets: ["GraphQLKit"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-syntax.git",
            from: "509.0.0-swift-5.9-DEVELOPMENT-SNAPSHOT-2023-04-25-b"
        ),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON", .upToNextMajor(from: "5.0.1")),
        .package(url: "https://github.com/david-swift/ColibriComponents-macOS", .upToNextMajor(from: "0.1.6")),
        .package(url: "https://github.com/lukepistrol/SwiftLintPlugin", from: "0.2.6")
    ],
    targets: [
        .macro(
            name: "GraphQLKitMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftyJSON", package: "SwiftyJSON")
            ],
            plugins: [
                .plugin(name: "SwiftLint", package: "SwiftLintPlugin")
            ]
        ),
        .target(
            name: "GraphQLKit",
            dependencies: [
                "GraphQLKitMacros",
                .product(name: "ColibriComponents", package: "ColibriComponents-macOS")
            ],
            plugins: [
                .plugin(name: "SwiftLint", package: "SwiftLintPlugin")
            ]
        ),
        .testTarget(
            name: "GraphQLKitTests",
            dependencies: [
                "GraphQLKitMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ],
            plugins: [
                .plugin(name: "SwiftLint", package: "SwiftLintPlugin")
            ]
        )
    ]
)
