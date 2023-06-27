<p align="center">
  <img width="256" alt="GraphQLKit Icon" src="Icons/GraphQLKitIcon.png">
  <h1 align="center">GraphQLKit</h1>
</p>

<p align="center">
  <a href="https://github.com/david-swift/GraphQLKit-macOS">
  GitHub
  </a>
  ·
  <a href="https://github.com/david-swift/GraphQLKit-macOS/tree/main/Tests/GraphQLKitTest/GraphQLKitTest">
  Examples
  </a>
  ·
  <a href="Documentation/Reference/README.md">
  Contributor Docs
  </a>
</p>

_GraphQLKit_ allows creating GraphQL queries using a simple and “swifty” syntax. Instead of first defining what data to fetch and later looking for that data in the JSON you get from the API, _GraphQLKit_ combines both into one step. Additionally, you get many advanced features from Swift for building requests, such as loops, if/else-statements and references to variables, right in the DSL. Here is a basic example using [GraphQLZero][1]:

```swift
var id = ""
var name = ""
try await GraphQL(url: "https://graphqlzero.almansi.me/api").query {
    UserQuery(id: "1", fields: .init(
        id: { id = $0 },
        name: { name = $0 }
    ))
}
```

## Table of Contents

- [Elements][2]
- [Installation][3]
- [Usage][4]
- [Thanks][5]

## Elements

| Name    | Description                                                        |
| ------- | ------------------------------------------------------------------ |
| GraphQL | Create and use GraphQL queries and mutations with any GraphQL API. |

## Installation

### Swift Package
1. Open your Swift package in Xcode.
2. Navigate to `File > Add Packages`.
3. Paste this URL into the search field: `https://github.com/david-swift/GraphQLKit-macOS`
4. Click on `Copy Dependency`.
5. Navigate to the `Package.swift` file.
6. In the `Package` initializer, under `dependencies`, paste the dependency into the array.

###  Xcode Project
1. Open your Xcode project in Xcode.
2. Navigate to `File > Add Packages`.
3. Paste this URL into the search field: `https://github.com/david-swift/GraphQLKit-macOS`
4. Click on `Add Package`.

## Usage

### Transfer the API’s Data Structure
The first step for creating type-safe GraphQL queries and mutations in Swift is transferring the API’s types. 

#### Create a Query Type
Create a query using `@GraphQLQuery`:

```swift
@GraphQLQuery
struct UserQuery {

    static var query: String { "user" }
    var id: String
    var fields: User.Fields

}
```

That is an example implementation of the query `user(id: ID!): User`.  

Every query contains the static `query` variable, defining the textual representation of the query. `id` in that example is an argument. You can use any data type conforming to the `GraphQLValueType` protocol. Those are `Array`, `Bool`, `String`, `Double`, `Int` and `URL` and any other type you extend. `fields` is a variable that is required in every query. `User` is a GraphQL object. Read the next section for learning how to create one.

#### Create a GraphQL Object
Any type in the GraphQL API that has fields (child variables) can be transferred using `@GraphQLObject`:

```swift
@GraphQLObject
final class User {

    var address: Address?
    @Value var id: String? = nil
    @Arguments(["options": PageQueryOptions()])
    var posts: PostsPage? = nil

}
```

That is an example implementation of the following type:
```graphql
type User {
   
    address: Address
    id: ID
    posts(options: PageQueryOptions): PostsPage       

}                      
```

There are different types of children. Children without any wrapper are other GraphQL objects. In queries and mutations, it can be configured which of their children to return. Children marked with `@Value` are types without any children, normally strings, numbers, etc. Children with `@Arguments(_:)` are types with arguments that behave almost like a query in a query. 

Note that every type is optional, as every child type can be omitted in the query or mutation and is therefore not contained in the returned JSON.

#### Create a GraphQL Mutation
Create a mutation using `@GraphQLMutation`:

```swift
@GraphQLMutation
struct CreateAlbum {

    static var query: String { "createAlbum" }
    var input: CreateAlbumInput
    var fields: Album.Fields

}
```

That is an example implementation of the mutation `createAlbum(input: CreateAlbumInput!): Album`. 

Define a mutation in the same way as you would define a query, but use the `@GraphQLMutation` macro.

### Creating a Request
Now, it’s time for using the transferred API structure in Swift and creating a request. Here is an example query:

```swift
try await GraphQL(url: "https://graphqlzero.almansi.me/api").query {
    UserQuery(id: "1", fields: .init(
        id: { print($0) },
        address: .init(
            geo: .init(
                lat: { print($0) },
                lng: { print($0) }
            )
        )
    ))
}             
```

That is an example implementation of the following query:

```graphql
query {
  user(id: "1") {
    id
    address {
      geo {
        lat
        lng
      }
    }
  }
}                       
```

Instead of getting the data and having to manually find the data you requested in a second step, only one step is required in `GraphQLKit`. You define what happens after fetching the data at the same time as you define what data to fetch. In the example above, the data is printed after being fetched successfully.  

Many Swift features, such as loops, switch statements, and many more, enhance the way you create GraphQL requests.

For mutations, use `mutation(mutations:getRequest:)` instead of `query(queries:getRequest:)`.  

## Thanks

### Dependencies
- [SwiftSyntax][6] licensed under the [Apache License 2.0][7]
- [SwiftyJSON][8] licensed under the [MIT license][9]
- [SwiftLintPlugin][10] licensed under the [MIT license][11]
- [ColibriComponents][12] licensed under the [MIT license][13]

### Other Thanks
- The [contributors][14]
- [SwiftLint][15] for checking whether code style conventions are violated
- [GitHub GraphQL API V4 client][16] as the design of `GraphQL` is inspired by the `GitHub` structure
- The programming language [Swift][17]
- [SourceDocs][18] used for generating the [docs][19]

[1]:	https://graphqlzero.almansi.me
[2]:	#Elements
[3]:	#Installation
[4]:	#Usage
[5]:	#Thanks
[6]:	https://github.com/apple/swift-syntax
[7]:	https://github.com/apple/swift-syntax/blob/main/LICENSE.txt
[8]:	https://github.com/SwiftyJSON/SwiftyJSON
[9]:	https://github.com/SwiftyJSON/SwiftyJSON/blob/master/LICENSE
[10]:	https://github.com/lukepistrol/SwiftLintPlugin
[11]:	https://github.com/lukepistrol/SwiftLintPlugin/blob/main/LICENSE
[12]:	https://github.com/david-swift/ColibriComponents-macOS
[13]:	https://github.com/david-swift/ColibriComponents-macOS/blob/main/LICENSE.md
[14]:	Contributors.md
[15]:	https://github.com/realm/SwiftLint
[16]:	https://github.com/eneko/GitHub
[17]:	https://github.com/apple/swift
[18]:   https://github.com/SourceDocs/SourceDocs
[19]:   Documentation/Reference/README.md
