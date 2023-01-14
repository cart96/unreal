defmodule Unreal do
  alias Unreal.Protocols
  alias Unreal.Core

  @type connection :: GenServer.server()
  @type result :: Core.Result.t() | list(Core.Result.t()) | Core.Error.t()

  @spec start_link({:http | :ws, Core.Conn.t()}) :: :ignore | {:error, any} | {:ok, pid}
  def start_link({:http, conn}) do
    GenServer.start_link(Protocols.HTTP, conn)
  end

  def start_link({:ws, conn}) do
    GenServer.start_link(Protocols.WebSocket, conn)
  end

  @spec use(connection, String.t(), String.t()) :: :ok
  def use(pid, namespace, database) do
    GenServer.cast(pid, {:use, namespace, database})
  end

  @spec signin(connection, String.t(), String.t(), String.t() | nil) :: :ok
  def signin(pid, username, password, scope \\ nil) do
    data =
      if is_nil(scope) do
        %{user: username, pass: password}
      else
        %{user: username, pass: password, sc: scope}
      end

    GenServer.cast(pid, {:signin, data})
  end

  @spec query(connection, String.t()) :: result
  def query(pid, command) do
    GenServer.call(pid, {:query, command, %{}})
    |> get_first()
  end

  @spec query(connection, String.t(), map) :: result
  def query(pid, command, vars) do
    GenServer.call(pid, {:query, command, vars})
    |> get_first()
  end

  @spec get_table(connection, String.t()) :: result
  def get_table(pid, table) do
    GenServer.call(pid, {:get_table, table})
    |> get_first()
  end

  @spec drop_table(connection, String.t()) :: result
  def drop_table(pid, table) do
    GenServer.call(pid, {:delete_table, table})
    |> get_first()
  end

  @spec insert(connection, String.t(), any) :: result
  def insert(pid, table, data) do
    GenServer.call(pid, {:insert_table, table, data})
    |> get_first()
  end

  @spec insert(connection, String.t(), String.t(), any) :: result
  def insert(pid, table, id, data) do
    GenServer.call(pid, {:insert_object, table, id, data})
    |> get_first()
  end

  @spec get(connection, String.t(), String.t()) :: result
  def get(pid, table, id) do
    GenServer.call(pid, {:get_object, table, id})
    |> get_first()
  end

  @spec update(connection, String.t(), String.t(), any) :: result
  def update(pid, table, id, data) do
    GenServer.call(pid, {:update_object, table, id, data})
    |> get_first()
  end

  @spec patch(connection, String.t(), String.t(), any) :: result
  def patch(pid, table, id, data) do
    GenServer.call(pid, {:patch_object, table, id, data})
    |> get_first()
  end

  @spec delete(connection, String.t(), String.t()) :: result
  def delete(pid, table, id) do
    GenServer.call(pid, {:delete_object, table, id})
    |> get_first()
  end

  defp get_first([arg]), do: arg
  defp get_first(arg), do: arg
end
