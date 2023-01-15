defmodule Unreal.Protocols.HTTP do
  use GenServer
  alias Unreal.Core

  @impl true
  def init(conn) do
    {:ok, conn}
  end

  @impl true
  def handle_call({:signin, username, password}, _from, conn) do
    {:reply, {:ok, nil}, %{conn | username: username, password: password}}
  end

  @impl true
  def handle_call({:signup, _data}, _from, socket) do
    {:reply, {:ok, nil}, socket}
  end

  @impl true
  def handle_call({:use, namespace, database}, _from, conn) do
    {:reply, {:ok, nil}, %{conn | namespace: namespace, database: database}}
  end

  @impl true
  def handle_call(:ping, _from, socket) do
    {:reply, {:ok, nil}, socket}
  end

  @impl true
  def handle_call(:info, _from, socket) do
    {:reply, {:ok, nil}, socket}
  end

  @impl true
  def handle_call({:query, command}, _from, conn) do
    result =
      Core.HTTP.Request.build(:post, conn, "/sql", command)
      |> Core.HTTP.request()

    {:reply, result, conn}
  end

  @impl true
  def handle_call({:query, command, _vars}, _from, conn) do
    result =
      Core.HTTP.Request.build(:post, conn, "/sql", command)
      |> Core.HTTP.request()

    {:reply, result, conn}
  end

  @impl true
  def handle_call({:insert_table, table, data}, _from, conn) do
    result =
      Core.HTTP.Request.build(:post, conn, "/key/#{table}", Jason.encode!(data))
      |> Core.HTTP.request()

    {:reply, result, conn}
  end

  @impl true
  def handle_call({:get_table, table}, _from, conn) do
    result =
      Core.HTTP.Request.build(:get, conn, "/key/#{table}", nil)
      |> Core.HTTP.request()

    {:reply, result, conn}
  end

  @impl true
  def handle_call({:delete_table, table}, _from, conn) do
    result =
      Core.HTTP.Request.build(:delete, conn, "/key/#{table}", nil)
      |> Core.HTTP.request()

    {:reply, result, conn}
  end

  @impl true
  def handle_call({:insert_object, table, id, data}, _from, conn) do
    result =
      Core.HTTP.Request.build(:post, conn, "/key/#{table}/#{id}", Jason.encode!(data))
      |> Core.HTTP.request()

    {:reply, result, conn}
  end

  @impl true
  def handle_call({:get_object, table, id}, _from, conn) do
    result =
      Core.HTTP.Request.build(:get, conn, "/key/#{table}/#{id}", nil)
      |> Core.HTTP.request()

    {:reply, result, conn}
  end

  @impl true
  def handle_call({:update_object, table, id, data}, _from, conn) do
    result =
      Core.HTTP.Request.build(:put, conn, "/key/#{table}/#{id}", Jason.encode!(data))
      |> Core.HTTP.request()

    {:reply, result, conn}
  end

  @impl true
  def handle_call({:patch_object, table, id, data}, _from, conn) do
    result =
      Core.HTTP.Request.build(:patch, conn, "/key/#{table}/#{id}", Jason.encode!(data))
      |> Core.HTTP.request()

    {:reply, result, conn}
  end

  @impl true
  def handle_call({:delete_object, table, id}, _from, conn) do
    result =
      Core.HTTP.Request.build(:delete, conn, "/key/#{table}/#{id}", nil)
      |> Core.HTTP.request()

    {:reply, result, conn}
  end
end
