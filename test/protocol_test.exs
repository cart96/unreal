defmodule UnrealProtocolTest do
  use ExUnit.Case

  setup_all do
    config_http = %Unreal.Core.Config{
      host: "http://127.0.0.1:8000",
      namespace: "test",
      database: "test",
      username: "root",
      password: "root"
    }

    config_ws = %{config_http | host: "ws://127.0.0.1:8000"}

    Unreal.start_link(protocol: :http, config: config_http, name: :database_http)
    Unreal.start_link(protocol: :websocket, config: config_ws, name: :database_ws)

    Unreal.delete(:database_http, "users")

    {:ok, []}
  end

  test "Test HTTP Connection", _state do
    {:ok, result} = Unreal.insert(:database_http, "users", "bob", %{age: 19, verified: true})

    assert result["id"] == "users:bob"
    assert result["age"] == 19
    assert result["verified"] == true

    {:ok, result} = Unreal.get(:database_http, "users", "bob")

    assert result["age"] == 19
    assert result["verified"] == true

    {:ok, result} = Unreal.change(:database_http, "users", "bob", %{verified: false})

    assert result["age"] == 19
    assert result["verified"] == false

    {:ok, result} = Unreal.update(:database_http, "users", "bob", %{age: 24})

    assert result["age"] == 24
    assert result["verified"] == nil
  end

  test "Test WebSocket Connection", _state do
    {:ok, result} = Unreal.insert(:database_ws, "users", "dude", %{age: 19, verified: true})

    assert result["id"] == "users:dude"
    assert result["age"] == 19
    assert result["verified"] == true

    {:ok, result} = Unreal.get(:database_ws, "users", "dude")

    assert result["age"] == 19
    assert result["verified"] == true

    {:ok, result} = Unreal.change(:database_ws, "users", "dude", %{verified: false})

    assert result["age"] == 19
    assert result["verified"] == false

    {:ok, result} = Unreal.update(:database_ws, "users", "dude", %{age: 24})

    assert result["age"] == 24
    assert result["verified"] == nil
  end
end
