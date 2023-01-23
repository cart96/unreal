defmodule Unreal.Core.WebSocket do
  @moduledoc false

  alias Unreal.Core

  defmodule Request do
    @moduledoc false

    @enforce_keys [:ws, :id, :method, :params]
    defstruct [:ws, :id, :method, :params]

    @type t :: %__MODULE__{
            ws: Socket.Web.t(),
            id: String.t(),
            method: String.t(),
            params: list
          }

    @spec build(Socket.Web.t(), String.t(), list) :: t()
    def build(conn, method, params) do
      id = :crypto.strong_rand_bytes(10) |> Base.encode32()

      %__MODULE__{
        ws: conn,
        id: id,
        method: method,
        params: params
      }
    end
  end

  @spec request(Core.WebSocket.Request.t(), keyword) :: Core.Result.t()
  def request(
        %Core.WebSocket.Request{ws: conn, id: id} = request,
        options
      ) do
    init_async_listener(conn)

    task = Task.async(__MODULE__, :async_request, [request])

    conn
    |> connection_to_id
    |> :ets.insert({id, task.pid})

    case Task.yield(task, options[:timeout] || 5000) || Task.shutdown(task) do
      {:ok, result} ->
        result

      _ ->
        {:error, "WebSocket response timed out"}
    end
  end

  def async_request(%Core.WebSocket.Request{ws: conn} = request) do
    data = request |> Map.from_struct() |> Map.delete(:ws) |> Jason.encode!()
    Socket.Web.send!(conn, {:text, data})

    receive do
      result -> result
    end
  end

  def init_async_listener(conn) do
    connection_id = connection_to_id(conn)

    if :ets.whereis(connection_id) == :undefined do
      :ets.new(connection_id, [:set, :protected, :named_table])
      spawn(__MODULE__, :async_listener, [conn])
    end
  end

  def async_listener(conn) do
    connection_id = connection_to_id(conn)

    {id, result} =
      case Socket.Web.recv!(conn) do
        {:text, data} ->
          data = Jason.decode!(data)

          if is_nil(data["error"]) do
            {data["id"], Core.Result.build(data["result"])}
          else
            {data["id"], {:error, data["error"]["message"]}}
          end

        _ ->
          {nil, {:error, "websocket receive error"}}
      end

    case :ets.lookup(connection_id, id) do
      [{_key, pid} | _other] ->
        send(pid, result)

      _ ->
        nil
    end

    async_listener(conn)
  end

  # Result is guaranteed to be less than 255 (max value length "134217727" is 9. with "unreal_", 9 + 7 = 16)
  defp connection_to_id(conn) do
    String.to_atom("unreal_" <> to_string(:erlang.phash2(conn)))
  end
end
