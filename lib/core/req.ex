defmodule Unreal.Core.Req do
  @enforce_keys [:url, :headers, :sql]
  defstruct [:url, :headers, :sql]

  def build(%Unreal.Core.Conn{
        namespace: namespace,
        database: database,
        user: user,
        password: password,
        host: host
      }) do
    auth = :base64.encode(user <> ":" <> password)

    %Unreal.Core.Req{
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
