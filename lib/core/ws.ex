defmodule Unreal.Core.WebSocket do
  alias Unreal.Core

  defmodule Request do
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

  @spec request(Core.WebSocket.Request.t()) :: Core.Result.t()
  def request(%Core.WebSocket.Request{ws: conn, id: id} = request) do
    init_async_listener(conn)

    task = Task.async(__MODULE__, :async_request, [request])
    :ets.insert(:unreal_async, {id, task.pid})

    Task.await(task)
  end

  def async_request(%Core.WebSocket.Request{ws: conn} = request) do
    Socket.Web.send!(
      conn,
      {:text, request |> Map.from_struct() |> Map.delete(:ws) |> Jason.encode!()}
    )

    receive do
      result -> result
    end
  end

  def init_async_listener(conn) do
    if :ets.whereis(:unreal_async) === :undefined do
      :ets.new(:unreal_async, [:set, :protected, :named_table])
      spawn(__MODULE__, :async_listener, [conn])
    end
  end

  def async_listener(conn) do
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

    case :ets.lookup(:unreal_async, id) do
      [{_key, pid} | _other] ->
        send(pid, result)

      _ ->
        nil
    end

    async_listener(conn)
  end
end
