defmodule UnrealTest do
  use ExUnit.Case
  doctest Unreal

  test "greets the world" do
    assert Unreal.hello() == :world
  end
end
