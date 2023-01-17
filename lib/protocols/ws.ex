defmodule Unreal.Protocols.WebSocket do
  use GenServer
  alias Unreal.Core

  @impl true
  def init(config) do
    socket = Socket.connect!("#{config.host}/rpc")

    auth_data = %{
      id: "_auth",
      method: "signin",
      params: [%{user: config.username, pass: config.password}]
    }

    use_data = %{
      id: "_use",
      method: "use",
      params: [config.namespace, config.database]
    }

    Socket.Web.send!(socket, {:text, Jason.encode!(auth_data)})
    Socket.Web.recv!(socket)

    Socket.Web.send!(socket, {:text, Jason.encode!(use_data)})
    Socket.Web.recv!(socket)

    {:ok, socket}
  end

  @impl true
  def handle_call({:signin, data}, _from, socket) do
    result =
      Core.WebSocket.Request.build(socket, "signin", [data])
      |> Core.WebSocket.request()

    {:reply, result, socket}
  end

  @impl true
  def handle_call({:signup, data}, _from, socket) do
    result =
      Core.WebSocket.Request.build(socket, "signup", [data])
      |> Core.WebSocket.request()

    {:reply, result, socket}
  end

  @impl true
  def handle_call({:use, namespace, database}, _from, socket) do
    result =
      Core.WebSocket.Request.build(socket, "use", [namespace, database])
      |> Core.WebSocket.request()

    {:reply, result, socket}
  end

  @impl true
  def handle_call(:ping, _from, socket) do
    result =
      Core.WebSocket.Request.build(socket, "ping", [])
      |> Core.WebSocket.request()

    {:reply, result, socket}
  end

  @impl true
  def handle_call(:info, _from, socket) do
    result =
      Core.WebSocket.Request.build(socket, "info", [])
      |> Core.WebSocket.request()

    {:reply, result, socket}
  end

  @impl true
  def handle_call({:query, command, vars}, _from, socket) do
    result =
      Core.WebSocket.Request.build(socket, "query", [command, vars])
      |> Core.WebSocket.request()

    {:reply, result, socket}
  end

  @impl true
  def handle_call({:insert_table, table, data}, _from, socket) do
    result =
      Core.WebSocket.Request.build(socket, "create", [table, data])
      |> Core.WebSocket.request()

    {:reply, result, socket}
  end

  @impl true
  def handle_call({:get_table, table}, _from, socket) do
    result =
      Core.WebSocket.Request.build(socket, "select", [table])
      |> Core.WebSocket.request()

    {:reply, result, socket}
  end

  @impl true
  def handle_call({:update_table, table, data}, _from, socket) do
    result =
      Core.WebSocket.Request.build(socket, "update", [table, data])
      |> Core.WebSocket.request()

    {:reply, result, socket}
  end

  @impl true
  def handle_call({:change_table, table, data}, _from, socket) do
    result =
      Core.WebSocket.Request.build(socket, "change", [table, data])
      |> Core.WebSocket.request()

    {:reply, result, socket}
  end

  @impl true
  def handle_call({:modify_table, table, data}, _from, socket) do
    result =
      Core.WebSocket.Request.build(socket, "modify", [table, data])
      |> Core.WebSocket.request()

    {:reply, result, socket}
  end

  @impl true
  def handle_call({:delete_table, table}, _from, socket) do
    result =
      Core.WebSocket.Request.build(socket, "delete", [table])
      |> Core.WebSocket.request()

    {:reply, result, socket}
  end

  @impl true
  def handle_call({:insert_object, table, id, data}, _from, socket) do
    result =
      Core.WebSocket.Request.build(socket, "create", ["#{table}:#{id}", data])
      |> Core.WebSocket.request()

    {:reply, result, socket}
  end

  @impl true
  def handle_call({:get_object, table, id}, _from, socket) do
    result =
      Core.WebSocket.Request.build(socket, "select", ["#{table}:#{id}"])
      |> Core.WebSocket.request()

    {:reply, result, socket}
  end

  @impl true
  def handle_call({:update_object, table, id, data}, _from, socket) do
    result =
      Core.WebSocket.Request.build(socket, "update", ["#{table}:#{id}", data])
      |> Core.WebSocket.request()

    {:reply, result, socket}
  end

  @impl true
  def handle_call({:change_object, table, id, data}, _from, socket) do
    result =
      Core.WebSocket.Request.build(socket, "change", ["#{table}:#{id}", data])
      |> Core.WebSocket.request()

    {:reply, result, socket}
  end

  @impl true
  def handle_call({:modify_object, table, id, data}, _from, socket) do
    result =
      Core.WebSocket.Request.build(socket, "modify", ["#{table}:#{id}", data])
      |> Core.WebSocket.request()

    {:reply, result, socket}
  end

  @impl true
  def handle_call({:delete_object, table, id}, _from, socket) do
    result =
      Core.WebSocket.Request.build(socket, "delete", ["#{table}:#{id}"])
      |> Core.WebSocket.request()

    {:reply, result, socket}
  end

  @impl true
  def handle_call(:invalidate, _from, socket) do
    result =
      Core.WebSocket.Request.build(socket, "invalidate", [])
      |> Core.WebSocket.request()

    {:reply, result, socket}
  end

  @impl true
  def handle_call({:let, key, value}, _from, socket) do
    result =
      Core.WebSocket.Request.build(socket, "let", [key, Jason.encode!(value)])
      |> Core.WebSocket.request()

    {:reply, result, socket}
  end
end
