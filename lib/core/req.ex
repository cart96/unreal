defmodule Unreal.Core.Request do
  alias Unreal.Core

  @enforce_keys [:method, :url, :headers, :command]
  defstruct [:method, :url, :headers, :command]

  @type t :: %__MODULE__{
          method: :get | :post | :put | :patch | :delete,
          url: String.t(),
          headers: list({String.t(), String.t()}),
          command: String.t() | nil
        }

  @spec build(atom, Core.Conn.t(), binary, binary | nil) :: Unreal.Core.Request.t()
  def build(
        method,
        %Core.Conn{
          namespace: namespace,
          database: database,
          user: user,
          password: password,
          host: host
        },
        path
      ) do
    auth = :base64.encode(user <> ":" <> password)

    %__MODULE__{
      method: method,
      url: host <> path,
      headers: [
        {"Accept", "application/json"},
        {"NS", namespace},
        {"DB", database},
        {"Authorization", "Basic #{auth}"}
      ],
      command: nil
    }
  end

  def build(method, conn, path, command) do
    %{build(method, conn, path) | command: command}
  end
end
