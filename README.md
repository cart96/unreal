# Unreal

Unofficial SurrealDB client for Elixir. Supports both WebSocket and HTTP connection.

**NOTE**: Currently, Unreal is complete library for simple projects. But I am trying to improve it for large projects.

## Installation

Add `unreal` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:unreal, "~> 0.1.0"}
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

This feature is inspired from [Cirql](https://github.com/StarlaneStudios/cirql) and currently not finished.

```elixir
alias Unreal.Writer

{query, params} =
  Writer.Select.init()
  |> Writer.Select.from("users")
  |> Writer.Select.get([:id, :username, :age])
  |> Writer.Select.where(age: {:>, 18}, verified: true)

{:ok, result} = Unreal.query(:database, query, params)
```

## Documentation

Documentation is avaible at [HexDocs](https://hexdocs.pm/unreal).

## Contributing

- Please don't send any pull request to main branch.
- Report bugs or request features [here](https://github.com/cart96/unreal/issues).
- Always use `mix format` before sending a pull request.

## License

Unreal is licensed under the MIT License.
