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

  @spec request(Core.WebSocket.Request.t()) :: list(Core.Result.t()) | Core.Error.t()
  def request(%Core.WebSocket.Request{ws: conn} = request) do
    Socket.Web.send!(
      conn,
      {:text, request |> Map.from_struct() |> Map.delete(:ws) |> Jason.encode!()}
    )

    case Socket.Web.recv!(conn) do
      {:text, data} ->
        data = Jason.decode!(data)

        if is_nil(data["error"]) do
          Core.Result.build(data["result"])
        else
          %Core.Error{
            code: data["error"]["code"] || 0,
            message: data["error"]["message"] || ""
          }
        end

      _ ->
        %Core.Error{
          code: 1,
          message: "Connection error."
        }
    end
  end
end
