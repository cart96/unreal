defmodule Unreal.Protocols.HTTP do
  use GenServer
  alias Unreal.Core

  @impl true
  def init(config) do
    {:ok, config}
  end

  @impl true
  def handle_call({:signin, username, password}, _from, config) do
    {:reply, {:ok, nil}, %{config | username: username, password: password}}
  end

  @impl true
  def handle_call({:signup, _data}, _from, socket) do
    {:reply, {:ok, nil}, socket}
  end

  @impl true
  def handle_call({:use, namespace, database}, _from, config) do
    {:reply, {:ok, nil}, %{config | namespace: namespace, database: database}}
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
  def handle_call({:query, command}, _from, config) do
    result =
      Core.HTTP.Request.build(:post, config, "/sql", command)
      |> Core.HTTP.request()

    {:reply, result, config}
  end

  @impl true
  def handle_call({:query, command, vars}, _from, config) do
    result =
      Core.HTTP.Request.build(:post, config, "/sql", command)
      |> Core.HTTP.Request.add_params(vars)
      |> Core.HTTP.request()

    {:reply, result, config}
  end

  @impl true
  def handle_call({:insert_table, table, data}, _from, config) do
    result =
      Core.HTTP.Request.build(:post, config, "/key/#{table}", Jason.encode!(data))
      |> Core.HTTP.request()

    {:reply, result, config}
  end

  @impl true
  def handle_call({:get_table, table}, _from, config) do
    result =
      Core.HTTP.Request.build(:get, config, "/key/#{table}", nil)
      |> Core.HTTP.request()

    {:reply, result, config}
  end

  @impl true
  def handle_call({:delete_table, table}, _from, config) do
    result =
      Core.HTTP.Request.build(:delete, config, "/key/#{table}", nil)
      |> Core.HTTP.request()

    {:reply, result, config}
  end

  @impl true
  def handle_call({:insert_object, table, id, data}, _from, config) do
    result =
      Core.HTTP.Request.build(:post, config, "/key/#{table}/#{id}", Jason.encode!(data))
      |> Core.HTTP.request()

    {:reply, result, config}
  end

  @impl true
  def handle_call({:get_object, table, id}, _from, config) do
    result =
      Core.HTTP.Request.build(:get, config, "/key/#{table}/#{id}", nil)
      |> Core.HTTP.request()

    {:reply, result, config}
  end

  @impl true
  def handle_call({:update_object, table, id, data}, _from, config) do
    result =
      Core.HTTP.Request.build(:put, config, "/key/#{table}/#{id}", Jason.encode!(data))
      |> Core.HTTP.request()

    {:reply, result, config}
  end

  @impl true
  def handle_call({:patch_object, table, id, data}, _from, config) do
    result =
      Core.HTTP.Request.build(:patch, config, "/key/#{table}/#{id}", Jason.encode!(data))
      |> Core.HTTP.request()

    {:reply, result, config}
  end

  @impl true
  def handle_call({:delete_object, table, id}, _from, config) do
    result =
      Core.HTTP.Request.build(:delete, config, "/key/#{table}/#{id}", nil)
      |> Core.HTTP.request()

    {:reply, result, config}
  end
end
