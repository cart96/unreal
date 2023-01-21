defmodule UnrealWriterTest do
  use ExUnit.Case

  alias Unreal.Writer

  setup_all do
    Unreal.delete(:database_ws, "points")

    Unreal.insert(:database_ws, "points", "bob", %{verified: false, point: 20})
    Unreal.insert(:database_ws, "points", "dude", %{verified: true, point: 80})
    Unreal.insert(:database_ws, "points", "cat", %{verified: true, point: 100})

    {:ok, []}
  end

  test "Test Count Writer", _state do
    {query, params} =
      Writer.Count.init("points", point: {:>, 50})
      |> Writer.Count.build()

    {:ok, result} = Unreal.query(:database_ws, query, params)

    :logger.info(result |> inspect)

    assert result["count"] == 2
  end

  test "Test Update Writer", _state do
    {query, params} =
      Writer.Update.init("points", [point: {:+, 20}], point: {:>, 50})
      |> Writer.Update.build()

    {:ok, result} = Unreal.query(:database_ws, query, params)

    assert :erlang.length(result) == 2
  end

  test "Test Select Writer", _state do
    {query, params} =
      Writer.Select.init("points", [:point], verified: true)
      |> Writer.Select.build()

    {:ok, result} = Unreal.query(:database_ws, query, params)

    assert :erlang.length(result) == 2
  end

  test "Test Create Writer", _state do
    {query, params} =
      Writer.Create.init("points:lol", another: true)
      |> Writer.Create.build()

    {:ok, result} = Unreal.query(:database_ws, query, params)

    assert result["id"] == "points:lol"
    assert result["another"] == true
  end
end
