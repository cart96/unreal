defmodule Unreal.Core.Request do
  @enforce_keys [:url, :headers, :sql]
  defstruct [:url, :headers, :sql]

  @type t :: %__MODULE__{
          url: String.t(),
          headers: list({String.t(), String.t()}),
          sql: String.t()
        }

  @spec build(Unreal.Core.Conn.t(), binary) :: Unreal.Core.Request.t()
  def build(%Unreal.Core.Conn{
        namespace: namespace,
        database: database,
        user: user,
        password: password,
        host: host
      }) do
    auth = :base64.encode(user <> ":" <> password)

    %__MODULE__{
      url: host <> "/sql",
      headers: [
        {"Accept", "application/json"},
        {"NS", namespace},
        {"DB", database},
        {"Authorization", "Basic #{auth}"}
      ],
      sql: nil
    }
  end

  def build(conn, sql) do
    %{build(conn) | sql: sql}
  end
end
