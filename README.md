![](./assets/unreal.png)

# Unreal

Unofficial SurrealDB client for Elixir. Supports both WebSocket and HTTP connection.

> ⚠️ Unreal is well tested, but still may contain some bugs. Please report an issue if you got one. ⚠️

## Installation

Add `unreal` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:unreal, "~> 0.2.2"}
  ]
end
```

## Usage

### Simple WebSocket Connection

```elixir
config = %Unreal.Core.Config{
  host: "ws://127.0.0.1:8000",
  username: "root",
  password: "root",
  database: "test",
  namespace: "test"
}

{:ok, pid} = Unreal.start_link(protocol: :websocket, config: config, name: :database)

Unreal.insert(pid, "users", "bob", %{age: 18, active: true})
Unreal.get(:database, "users")
```

### With Supervisor

```elixir
children = [
  {Unreal,
    protocol: :websocket,
    config: %Unreal.Core.Config{
      host: "ws://127.0.0.1:8000",
      username: "root",
      password: "root",
      namespace: "test",
      database: "test"
    },
    name: :database}
]

opts = [strategy: :one_for_one, name: Example.Supervisor]

Supervisor.start_link(children, opts)
Unreal.insert(:database, "users", "bob", %{age: 18, active: true})
```

### With Tables

This macro allows you to use a table directly. Adds `insert`, `update`, `get`, `change`, `modify` and `delete` functions.

```elixir
defmodule Users do
  # name: the name of the connection
  # table: table to use
  use Unreal.Table, name: :database, table: "users"
end

Users.get("bob")
```

### Queries

**NOTE**: Sending a variable to query is not supported in HTTP connection.

```elixir
Unreal.query(:database, "SELECT * FROM users")
Unreal.query(:database, "SELECT * FROM users WHERE age > $age", %{
  age: 30
})
```

### Query Builders

This feature is inspired from [Cirql](https://github.com/StarlaneStudios/cirql) and currently supports 5 operations.

```elixir
alias Unreal.Writer

{query, params} =
  Writer.Select.init()
  |> Writer.Select.from("users")
  |> Writer.Select.get([:id, :username, :age])
  |> Writer.Select.where(age: {:ge, 18}, verified: true)
  |> Writer.Select.build()

{:ok, result} = Unreal.query(:database, query, params)
```

#### Operators

There are some operators you can pass when you use query builders with `set` or `where` operations:

- `:le`: Check whether a value is less than or equal to another value
- `:ge`: Check whether a value is greater than or equal to another value
- `:lt`: Check whether a value is less than another value
- `:gt`: Check whether a value is greater than another value
- `:add`: Add value to existing value (ONLY FOR UPDATING)
- `:dec`: Substract value to existing value (ONLY FOR UPDATING)
- `:ne`: Check whether two values are not equal
- `:any`: Check whether any value in a set is equal to a value
- `:all`: Check whether all values in a set are equal to a value
- `:in`: Checks whether a value is contained within another value
- `:ex`: Checks whether a value is not contained within another value

```elixir
# ...
|> Writer.Select.where(age: {:gt, 13}, verified: true)
# ...
```

As you can see, if we pass the value directly (like `verified: true`) it will generate it as equals operation.

And if you want to pass a custom operator, you can change first value of the tuple to anything you want.

```elixir
# ...
|> Writer.Select.where(thing: {"==", 26}) # Strict Equality
# ...
```

### Ways to Use Order of Preference

- Default functions like `insert`, `update`, `delete` etc. are the simplest way to use.
- For more flexible queries, use built-in query builders.
- If query builders are not enough, and you need to run something complex, use `query` function.

  ```elixir
  # NOTE: Query builders are flexible enough for this query.
  #       This is just an example.

  # Bad, allows users to inject SurrealQL commands.
  Unreal.query(pid, "SELECT token FROM users WHERE password = #{password}")

  # Good and safe.
  Unreal.query(pid, "SELECT token FROM users WHERE password = $pass", %{pass: password})
  ```

## Documentation

Documentation is avaible at [HexDocs](https://hexdocs.pm/unreal).

## Contributing

- Report bugs or request features [here](https://github.com/cart96/unreal/issues).
- Always use `mix format` before sending a pull request.

## License

Unreal is licensed under the MIT License.
