defmodule Unreal.Core.HTTP do
  alias Unreal.Core

  defmodule Request do
    @enforce_keys [:method, :url, :headers]
    defstruct [:method, :url, :headers, :command]

    @type t :: %__MODULE__{
            method: :get | :post | :put | :patch | :delete,
            url: String.t(),
            headers: list({String.t(), String.t()}),
            command: String.t() | nil
          }

    @spec build(atom, Core.Conn.t(), binary, binary | nil) :: t()
    def build(
          method,
          %Core.Conn{
            namespace: namespace,
            database: database,
            username: user,
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

  @spec request(Core.HTTP.Request.t()) :: Core.Result.t()
  def request(%Core.HTTP.Request{method: method, url: url, headers: headers, command: command}) do
    request = %HTTPoison.Request{
      method: method,
      url: url,
      headers: headers,
      body: command || ""
    }

    case HTTPoison.request(request) do
      {:ok, %{status_code: status, body: body}} ->
        case Jason.decode(body) do
          {:ok, data} ->
            if status === 200 do
              data
              |> Enum.map(fn %{"result" => result} -> Core.Result.build(result) end)
              |> fetch_result
            else
              {:error, data["information"] || data["description"] || data["details"]}
            end

          {:error, _} ->
            {:error, "http parse error"}
        end

      {:error, _} ->
        {:error, "http connection error"}
    end
  end

  defp fetch_result([value]), do: value
  defp fetch_result(value), do: value
end
