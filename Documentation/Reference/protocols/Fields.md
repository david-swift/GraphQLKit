**PROTOCOL**

# `Fields`

```swift
public protocol Fields
```

A protocol defining the content of fields.
You normally should not use that protocol directly in your code,
but add a fields type to a class using the `@GraphQLKitObject` macro.

## Properties
### `string`

```swift
var string: String
```

A textual description of the choices.

## Methods
### `get(value:)`

```swift
func `get`(value: Value)
```

Call the fields using a value.
- Parameter value: The value.

#### Parameters

| Name | Description |
| ---- | ----------- |
| value | The value. |