defmodule Unreal do
  @moduledoc """
  Main part of the driver. A wrapper for HTTP and WebSocket protocols.
  """

  alias Unreal.Protocols
  alias Unreal.Core

  @type connection :: GenServer.server()
  @type result :: Core.Result.t()

  @spec start_link(protocol: :http | :websocket, config: Unreal.Core.Config.t(), name: :atom) ::
          :ignore | {:error, any} | {:ok, pid}
  def start_link(protocol: :http, config: config, name: name) do
    GenServer.start_link(Protocols.HTTP, config, name: name)
  end

  def start_link(protocol: :websocket, config: config, name: name) do
    GenServer.start_link(Protocols.WebSocket, config, name: name)
  end

  @spec child_spec(any) :: %{id: Unreal, start: {Unreal, :start_link, [...]}}
  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  @doc """
  Signs in to a specific authentication scope.
  You don't need to run in first initialization if you specified your username and password on config.

      Unreal.signin(pid, "root", "root")
  """
  @spec signin(connection, String.t(), String.t(), String.t() | nil) :: result
  def signin(pid, username, password, scope \\ nil) do
    data =
      if is_nil(scope) do
        %{user: username, pass: password}
      else
        %{user: username, pass: password, sc: scope}
      end

    GenServer.call(pid, {:signin, data})
  end

  @doc """
  Signs this connection up to a specific authentication scope.
  Currently not working.
  """
  @spec signup(connection, String.t(), String.t(), String.t() | nil) :: result
  def signup(pid, username, password, scope \\ nil) do
    data =
      if is_nil(scope) do
        %{user: username, pass: password}
      else
        %{user: username, pass: password, sc: scope}
      end

    GenServer.call(pid, {:signup, data})
  end

  @doc """
  Switch to a specific namespace and database.

      Unreal.use(pid, "namespace", "database")
  """
  @spec use(connection, String.t(), String.t()) :: result
  def use(pid, namespace, database) do
    GenServer.call(pid, {:use, namespace, database})
  end

  @doc """
  Send a ping to WebSocket connection. Will do nothing for HTTP connection.

      Unreal.ping(pid)
  """
  @spec ping(connection) :: result
  def ping(pid) do
    GenServer.call(pid, :ping)
  end

  @doc """
  Get info. Will do nothing for HTTP connection.

      Unreal.info(pid)
  """
  @spec info(connection) :: result
  def info(pid) do
    GenServer.call(pid, :info)
  end

  @doc """
  Runs a set of SurrealQL statements against the database.

      Unreal.query(pid, "CREATE person; SELECT * FROM person;")
  """
  @spec query(connection, String.t()) :: result
  def query(pid, command) do
    GenServer.call(pid, {:query, command, %{}})
  end

  @doc """
  Runs a set of SurrealQL statements against the database with variables.

      Unreal.query(pid, "CREATE person; SELECT * FROM type::table($tb);", %{
        tb: "person"
      })
  """
  @spec query(connection, String.t(), map) :: result
  def query(pid, command, vars) do
    GenServer.call(pid, {:query, command, vars})
  end

  @doc """
  Creates a record in the database.

      Unreal.insert(pid, "users", %{key: "value"})
  """
  @spec insert(connection, String.t(), any) :: result
  def insert(pid, table, data) do
    GenServer.call(pid, {:insert_table, table, data})
  end

  @doc """
  Creates a record in the database with id.

      Unreal.insert(pid, "users", "bob", %{key: "value"})
  """
  @spec insert(connection, String.t(), String.t(), any) :: result
  def insert(pid, table, id, data) do
    case GenServer.call(pid, {:insert_object, table, id, data}) do
      {:ok, result} -> {:ok, List.first(result)}
      any -> any
    end
  end

  @doc """
  Selects all records in a table.

      Unreal.get(pid, "users")
  """
  @spec get(connection, String.t()) :: result
  def get(pid, table) do
    GenServer.call(pid, {:get_table, table})
  end

  @doc """
  Selects a specific record in a table.

      Unreal.get(pid, "users", "bob")
  """
  @spec get(connection, String.t(), String.t()) :: result
  def get(pid, table, id) do
    case GenServer.call(pid, {:get_object, table, id}) do
      {:ok, result} -> {:ok, List.first(result)}
      any -> any
    end
  end

  @doc """
  Updates all records in a table.

      Unreal.update(pid, "users", %{thing: true})
  """
  @spec update(connection, String.t(), any) :: result
  def update(pid, table, data) do
    GenServer.call(pid, {:update_table, table, data})
  end

  @doc """
  Updates a specific record in a table.

      Unreal.update(pid, "users", "bob", %{thing: true})
  """
  @spec update(connection, String.t(), String.t(), any) :: result
  def update(pid, table, id, data) do
    case GenServer.call(pid, {:update_object, table, id, data}) do
      {:ok, result} -> {:ok, List.first(result)}
      any -> any
    end
  end

  @doc """
  Modifies all records in a table.

      Unreal.change(pid, "users", %{active: true})
  """
  @spec change(connection, String.t(), any) :: result
  def change(pid, table, data) do
    GenServer.call(pid, {:change_table, table, data})
  end

  @doc """
  Modifies a specific record.

      Unreal.change(pid, "users", "bob", %{active: true})
  """
  @spec change(connection, String.t(), String.t(), any) :: result
  def change(pid, table, id, data) do
    case GenServer.call(pid, {:change_object, table, id, data}) do
      {:ok, result} -> {:ok, List.first(result)}
      any -> any
    end
  end

  @doc """
  Applies JSON Patch changes to all records. Only works for WebSocket connection.

      Unreal.modify(pid, "users", [
        { op: "replace", path: "/created_at", value: new Date() },
      ])
  """
  @spec modify(connection, String.t(), any) :: result
  def modify(pid, table, data) do
    GenServer.call(pid, {:modify_table, table, data})
  end

  @doc """
  Modifies a specific record. Only works for WebSocket connection.

      Unreal.modify(pid, "users", "bob", [
        { op: "replace", path: "/created_at", value: new Date() },
      ])
  """
  @spec modify(connection, String.t(), String.t(), any) :: result
  def modify(pid, table, id, data) do
    case GenServer.call(pid, {:modify_object, table, id, data}) do
      {:ok, result} -> {:ok, List.first(result)}
      any -> any
    end
  end

  @doc """
  Deletes all records in a table.

      Unreal.delete(pid, "users")
  """
  @spec delete(connection, String.t()) :: result
  def delete(pid, table) do
    GenServer.call(pid, {:delete_table, table})
  end

  @doc """
  Deletes a specific record in a table.

      Unreal.delete(pid, "users", "bob")
  """
  @spec delete(connection, String.t(), String.t()) :: result
  def delete(pid, table, id) do
    GenServer.call(pid, {:delete_object, table, id})
  end

  @doc """
  Invalidates the authentication for the current connection.

      Unreal.invalidate(pid)
  """
  @spec invalidate(connection) :: result
  def invalidate(pid) do
    GenServer.call(pid, :invalidate)
  end

  @doc """
  Assigns a value as a parameter for this connection. Only for WebSocket connection.

      Unreal.let(pid, "key", "value")
  """
  @spec let(connection, String.t(), any) :: result
  def let(pid, key, value) do
    GenServer.call(pid, {:let, key, value})
  end
end
