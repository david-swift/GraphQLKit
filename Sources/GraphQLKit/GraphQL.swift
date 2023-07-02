//
//  GraphQL.swift
//  GraphQLKit
//
//  Created by david-swift on 09.06.2023.
//

import ColibriComponents
import Foundation
import SwiftyJSON

/// A structure storing the API's URL for executing queries and mutations.
public struct GraphQL {

    /// The API's URL.
    public var url: String

    /// Initialize
    /// - Parameter url: The API's URL.
    public init(url: String) {
        self.url = url
    }

    /// A type for converting the data string into a request.
    struct Request: Codable {

        /// The data string.
        let query: String

    }

    /// Errors occuring while executing.
    public enum GraphQLError: Error {

        /// The URL is invalid.
        case invalidURL
        /// The request failed because of unknown reasons.
        case requestFailed

    }

    /// Execute queries.
    ///
    /// Call the query function in the way the following example shows:
    /// ```swift
    /// try await GraphQL(url: "https://graphqlzero.almansi.me/api").query {
    /// UserQuery(id: "1", fields: .init(
    ///        id: { print($0) },
    ///        name: { print($0) }
    ///    ))
    /// }
    /// ```
    /// Use the structure of your GraphQL API.
    /// If the request does not work, chances are that your API uses another URL syntax:
    /// Define the conversion from the URL you provided and the data as a `String` manually
    /// by calling ``query(queries:getRequest:)`` instead of omitting `getRequest`.
    ///
    /// - Parameters:
    ///   - queries: The queries.
    ///   - getRequest: A manual conversion from the URL data to the URL request. In many cases, you can omit it.
    ///   - editRequest: Edit the url request before the session is being started.
    public func query(
        @ArrayBuilder<Query> queries: () -> [any Query],
        getRequest: ((URL, String) -> URLRequest)? = nil,
        editRequest: (inout URLRequest) -> Void = { _ in }
    ) async throws {
        var data = "query {"
        for query in queries() {
            data.append(query.string)
        }
        data.append("}")
        let output = try await getAsync(data: data, getRequest: getRequest, editRequest: editRequest)
        if let json = try JSON(data: output)["data"].dictionary {
            for query in queries() {
                try query.get(data: json)
            }
        }
    }

    /// Execute mutations.
    ///
    /// Call the mutation function in the way the following example shows:
    /// ```swift
    /// try await GraphQL(url: "https://graphqlzero.almansi.me/api").mutation {
    ///     CreateAlbum(input: .init(
    ///         title: "Hi",
    ///         userId: "1"
    ///     ), fields: .init(
    ///         id: { print($0) },
    ///         title: { print($0) }
    ///     ))
    /// }
    /// ```
    /// Use the structure of your GraphQL API.
    /// If the request does not work, chances are that your API uses another URL syntax:
    /// Define the conversion from the URL you provided and the data as a `String` manually
    /// by calling ``mutation(mutations:getRequest:)`` instead of omitting `getRequest`.
    ///
    /// - Parameters:
    ///   - mutations: The mutations.
    ///   - getRequest: A manual conversion from the URL data to the URL request. In many cases, you can omit it.
    ///   - editRequest: Edit the url request before the session is being started.
    public func mutation(
        @ArrayBuilder<Mutation> mutations: () -> [any Mutation],
        getRequest: ((URL, String) -> URLRequest)? = nil,
        editRequest: (inout URLRequest) -> Void = { _ in }
    ) async throws {
        var data = "mutation {"
        for mutation in mutations() {
            data.append(mutation.string)
        }
        data.append("}")
        let output = try await getAsync(data: data, getRequest: getRequest, editRequest: editRequest)
        if let json = try JSON(data: output)["data"].dictionary {
            for mutation in mutations() {
                try mutation.get(data: json)
            }
        }
    }

    /// Execute a query asynchronously.
    /// - Parameters:
    ///   - data: The query or mutation data.
    ///   - getRequest: The custom URL & data to a URL request conversion.
    ///   - editRequest: Edit the URL request before the session starts.
    /// - Returns: The data.
    func getAsync(
        data: String,
        getRequest: ((URL, String) -> URLRequest)? = nil,
        editRequest: (inout URLRequest) -> Void
    ) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            try? getData(data: data, getRequest: getRequest, editRequest: editRequest) { response, error in
                if let response {
                    continuation.resume(returning: response)
                } else {
                    continuation.resume(throwing: error ?? GraphQLError.requestFailed)
                }
            }
        }
    }

    /// Get the data using a completion handler.
    /// - Parameters:
    ///   - data: The query or mutation data.
    ///   - getRequest: The custom URL & data to a URL request conversion.
    ///   - editRequest: Edit the URL request before the session starts.
    ///   - completion: The completion.
    func getData(
        data: String,
        getRequest: ((URL, String) -> URLRequest)? = nil,
        editRequest: (inout URLRequest) -> Void,
        completion: @escaping (Data?, Error?) -> Void
    ) throws {
        guard let url = URL(string: url) else {
            throw GraphQLError.invalidURL
        }
        var request: URLRequest
        if let getRequest {
            request = getRequest(url, data)
        } else {
            request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = try JSONEncoder().encode(Request(query: data))
        }
        editRequest(&request)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .init())
        let task = session.dataTask(with: request) { data, _, error in
            if let data {
                completion(data, nil)
            } else if let error {
                completion(nil, error)
            } else {
                completion(nil, nil)
            }
        }
        task.resume()
    }

}
