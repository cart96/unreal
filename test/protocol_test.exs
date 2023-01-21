defmodule UnrealProtocolTest do
  use ExUnit.Case

  setup_all do
    Unreal.delete(:database_ws, "users")

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
