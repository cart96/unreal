defmodule Unreal do
  alias Unreal.Protocols
  alias Unreal.Core

  @type connection :: GenServer.server()
  @type result :: Core.Result.t()

  @spec start_link([
          {:config, Core.Config.t()}
          | {:name, atom | {:global, any} | {:via, atom, any}}
          | {:protocol, :http | :websocket},
          ...
        ]) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(protocol: :http, config: config, name: name) do
    GenServer.start_link(Protocols.HTTP, config, name: name)
  end

  def start_link(protocol: :websocket, config: config, name: name) do
    GenServer.start_link(Protocols.WebSocket, config, name: name)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

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

  @spec use(connection, String.t(), String.t()) :: result
  def use(pid, namespace, database) do
    GenServer.call(pid, {:use, namespace, database})
  end

  @spec ping(connection) :: result
  def ping(pid) do
    GenServer.call(pid, :ping)
  end

  @spec info(connection) :: result
  def info(pid) do
    GenServer.call(pid, :info)
  end

  @spec query(connection, String.t()) :: result
  def query(pid, command) do
    GenServer.call(pid, {:query, command, %{}})
  end

  @spec query(connection, String.t(), map) :: result
  def query(pid, command, vars) do
    GenServer.call(pid, {:query, command, vars})
  end

  @spec insert(connection, String.t(), any) :: result
  def insert(pid, table, data) do
    GenServer.call(pid, {:insert_table, table, data})
  end

  @spec insert(connection, String.t(), String.t(), any) :: result
  def insert(pid, table, id, data) do
    case GenServer.call(pid, {:insert_object, table, id, data}) do
      {:ok, result} -> {:ok, List.first(result)}
      any -> any
    end
  end

  @spec get(connection, String.t()) :: result
  def get(pid, table) do
    GenServer.call(pid, {:get_table, table})
  end

  @spec get(connection, String.t(), String.t()) :: result
  def get(pid, table, id) do
    case GenServer.call(pid, {:get_object, table, id}) do
      {:ok, result} -> {:ok, List.first(result)}
      any -> any
    end
  end

  @spec update(connection, String.t(), String.t(), any) :: result
  def update(pid, table, id, data) do
    case GenServer.call(pid, {:update_object, table, id, data}) do
      {:ok, result} -> {:ok, List.first(result)}
      any -> any
    end
  end

  @spec patch(connection, String.t(), String.t(), any) :: result
  def patch(pid, table, id, data) do
    case GenServer.call(pid, {:patch_object, table, id, data}) do
      {:ok, result} -> {:ok, List.first(result)}
      any -> any
    end
  end

  @spec delete(connection, String.t()) :: result
  def delete(pid, table) do
    GenServer.call(pid, {:delete_table, table})
  end

  @spec delete(connection, String.t(), String.t()) :: result
  def delete(pid, table, id) do
    GenServer.call(pid, {:delete_object, table, id})
  end

  @spec invalidate(connection) :: result
  def invalidate(pid) do
    GenServer.call(pid, :invalidate)
  end

  @spec let(connection, String.t(), any) :: result
  def let(pid, key, value) do
    GenServer.call(pid, {:let, key, value})
  end
end
