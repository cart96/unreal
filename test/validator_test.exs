defmodule UnrealValidatorTest do
  alias Unreal.Validator
  use ExUnit.Case

  defmodule User do
    defstruct [:username, :age, :email, :password]
  end

  test "Validate Simple" do
    form = %{"username" => "dude", "age" => 16}

    result =
      Validator.start(form, User, [:username, :age])
      |> Validator.match(:username, ~r/^[a-z0-9_-]{3,15}$/)
      |> Validator.range(:username, 2..32)
      |> Validator.load(:age, {Kernel, :is_integer, []})
      |> Validator.minimum(:age, 13)
      |> Validator.error()

    assert result === nil
  end

  test "Validate Email" do
    form = %{"username" => "dude", "age" => 16, "email" => "test@example.com"}

    result =
      Validator.start(form, User, [:email])
      |> Validator.match(:email, :email)
      |> Validator.error()

    assert result === nil
  end

  test "Validate Password" do
    form = %{
      "username" => "dude",
      "age" => 16,
      "email" => "test@example.com",
      "password" => "very_unique",
      "password_confirm" => "very_unique"
    }

    result =
      Validator.start(form, User, [:password, :password_confirm])
      |> Validator.load(:password, {Kernel, :is_binary, []})
      |> Validator.range(:password, 8..72)
      |> Validator.same(:password, :password_confirm)
      |> Validator.error()

    assert result === nil
  end
end
