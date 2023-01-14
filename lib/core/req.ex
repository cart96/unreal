defmodule Unreal.Core.Request do
  @enforce_keys [:url, :headers, :command]
  defstruct [:url, :headers, :command]

  @type t :: %__MODULE__{
          url: String.t(),
          headers: list({String.t(), String.t()}),
          command: String.t()
        }

  @spec build(Unreal.Core.Conn.t(), binary, binary) :: Unreal.Core.Request.t()
  def build(
        %Unreal.Core.Conn{
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

  def build(conn, path, command) do
    %{build(conn, path) | command: command}
  end
end
