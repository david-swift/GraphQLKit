**STRUCT**

# `GraphQL`

```swift
public struct GraphQL
```

A structure storing the API's URL for executing queries and mutations.

## Properties
### `url`

```swift
public var url: String
```

The API's URL.

## Methods
### `init(url:)`

```swift
public init(url: String)
```

Initialize
- Parameter url: The API's URL.

#### Parameters

| Name | Description |
| ---- | ----------- |
| url | The API’s URL. |

### `query(queries:getRequest:)`

```swift
public func query(
    @ArrayBuilder<Query> queries: () -> [any Query],
    getRequest: ((URL, String) -> URLRequest)? = nil
) async throws
```

Execute queries.

Call the query function in the way the following example shows:
```swift
try await GraphQL(url: "https://graphqlzero.almansi.me/api").query {
UserQuery(id: "1", fields: .init(
       id: { print($0) },
       name: { print($0) }
   ))
}
```
Use the structure of your GraphQL API.
If the request does not work, chances are that your API uses another URL syntax:
Define the conversion from the URL you provided and the data as a `String` manually
by calling ``query(queries:getRequest:)`` instead of omitting `getRequest`.

- Parameters:
  - queries: The queries.
  - getRequest: A manual conversion from the URL data to the URL request. In many cases, you can omit it.

#### Parameters

| Name | Description |
| ---- | ----------- |
| queries | The queries. |
| getRequest | A manual conversion from the URL data to the URL request. In many cases, you can omit it. |

### `mutation(mutations:getRequest:)`

```swift
public func mutation(
    @ArrayBuilder<Mutation> mutations: () -> [any Mutation],
    getRequest: ((URL, String) -> URLRequest)? = nil
) async throws
```

Execute mutations.

Call the mutation function in the way the following example shows:
```swift
try await GraphQL(url: "https://graphqlzero.almansi.me/api").mutation {
    CreateAlbum(input: .init(
        title: "Hi",
        userId: "1"
    ), fields: .init(
        id: { print($0) },
        title: { print($0) }
    ))
}
```
Use the structure of your GraphQL API.
If the request does not work, chances are that your API uses another URL syntax:
Define the conversion from the URL you provided and the data as a `String` manually
by calling ``mutation(mutations:getRequest:)`` instead of omitting `getRequest`.

- Parameters:
  - mutations: The mutations.
  - getRequest: A manual conversion from the URL data to the URL request. In many cases, you can omit it.

#### Parameters

| Name | Description |
| ---- | ----------- |
| mutations | The mutations. |
| getRequest | A manual conversion from the URL data to the URL request. In many cases, you can omit it. |

### `getAsync(data:getRequest:)`

```swift
func getAsync(data: String, getRequest: ((URL, String) -> URLRequest)? = nil) async throws -> Data
```

Execute a query asynchronously.
- Parameters:
  - data: The query or mutation data.
  - getRequest: The custom URL & data to a URL request conversion.
- Returns: The data.

#### Parameters

| Name | Description |
| ---- | ----------- |
| data | The query or mutation data. |
| getRequest | The custom URL & data to a URL request conversion. |

### `getData(data:getRequest:completion:)`

```swift
func getData(
    data: String,
    getRequest: ((URL, String) -> URLRequest)? = nil,
    completion: @escaping (Data?, Error?) -> Void
) throws
```

Get the data using a completion handler.
- Parameters:
  - data: The query or mutation data.
  - getRequest: The custom URL & data to a URL request conversion.
  - completion: The completion.

#### Parameters

| Name | Description |
| ---- | ----------- |
| data | The query or mutation data. |
| getRequest | The custom URL & data to a URL request conversion. |
| completion | The completion. |