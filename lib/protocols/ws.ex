defmodule Unreal.Protocols.WebSocket do
  use GenServer
  alias Unreal.Core

  @impl true
  def init(%Core.Conn{host: host}) do
    socket = Socket.connect!("#{host}/rpc")
    {:ok, socket}
  end

  @impl true
  def handle_cast({:signin, data}, socket) do
    Core.WebSocket.Request.build(socket, "signin", [data])
    |> Core.WebSocket.request()

    {:noreply, socket}
  end

  @impl true
  def handle_cast({:use, namespace, database}, socket) do
    Core.WebSocket.Request.build(socket, "use", [namespace, database])
    |> Core.WebSocket.request()

    {:noreply, socket}
  end

  @impl true
  def handle_call({:query, command, vars}, _from, socket) do
    result =
      Core.WebSocket.Request.build(socket, "query", [command, vars])
      |> Core.WebSocket.request()

    {:reply, result, socket}
  end
end
