**PROTOCOL**

# `AnyQuery`

```swift
public protocol AnyQuery
```

The requirements of any query (either a query or mutation).
Normally, you should not need to call that protocol directly in your project.

## Properties
### `query`

```swift
static var query: String
```

The query's name.

### `string`

```swift
var string: String
```

A textual description of the query.

### `fields`

```swift
var fields: FieldsType
```

The fields.

## Methods
### `get(data:)`

```swift
func `get`(data: [String: JSON]) throws
```

Get the information by providing JSON data.
- Parameter data: An array containing the JSON data.

#### Parameters

| Name | Description |
| ---- | ----------- |
| data | An array containing the JSON data. |