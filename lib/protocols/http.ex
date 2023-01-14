defmodule Unreal.Protocols.HTTP do
  use GenServer
  alias Unreal.Core

  @spec init(Core.Conn.t()) :: {:ok, Core.Conn.t()}
  @impl true
  def init(conn) do
    {:ok, conn}
  end

  @impl true
  def handle_call({:query, command}, _from, conn) do
    result =
      Core.Request.build(conn, "/sql", command)
      |> Core.HTTP.request()

    {:reply, result, conn}
  end
end
