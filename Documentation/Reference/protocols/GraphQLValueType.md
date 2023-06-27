**PROTOCOL**

# `GraphQLValueType`

```swift
public protocol GraphQLValueType
```

The protocol a type has to conform to to be usable with `@Value` or as a `@Arguments` argument.
Types defined using the `@GraphQLObject` macro automatically conform to this protocol.
`Array`, `Bool`, `Double`, `Int`,  `String` and `URL` conform to this protocol.

## Properties
### `string`

```swift
var string: String
```

A textual representation for GraphQL queries and mutations.
