defmodule UnrealWriterTest do
  use ExUnit.Case

  alias Unreal.Writer

  setup_all do
    config = %Unreal.Core.Config{
      host: "ws://127.0.0.1:8000",
      namespace: "test",
      database: "test",
      username: "root",
      password: "root"
    }

    Unreal.start_link(protocol: :websocket, config: config, name: :database)

    Unreal.delete(:database, "users")

    Unreal.insert(:database, "users", "bob", %{verified: false, point: 20})
    Unreal.insert(:database, "users", "dude", %{verified: true, point: 80})
    Unreal.insert(:database, "users", "cat", %{verified: true, point: 100})

    {:ok, []}
  end

  test "Test Count Writer", _state do
    {query, params} =
      Writer.Count.init("users", point: {:>, 50})
      |> Writer.Count.build()

    {:ok, result} = Unreal.query(:database, query, params)

    assert result["count"] == 2
  end

  test "Test Update Writer", _state do
    {query, params} =
      Writer.Update.init("users", [point: {:+, 20}], point: {:>, 50})
      |> Writer.Update.build()

    {:ok, result} = Unreal.query(:database, query, params)

    assert :erlang.length(result) == 2
  end

  test "Test Select Writer", _state do
    {query, params} =
      Writer.Select.init("users", [:point], verified: true)
      |> Writer.Select.build()

    {:ok, result} = Unreal.query(:database, query, params)

    assert :erlang.length(result) == 2
  end

  test "Test Create Writer", _state do
    {query, params} =
      Writer.Create.init("users:lol", another: true)
      |> Writer.Create.build()

    {:ok, result} = Unreal.query(:database, query, params)

    assert result["id"] == "users:lol"
    assert result["another"] == true
  end
end
