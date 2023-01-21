defmodule Unreal.Core.HTTP do
  alias Unreal.Core

  defmodule Request do
    @enforce_keys [:method, :url, :headers]
    defstruct [:method, :url, :headers, :command, :params]

    @type t :: %__MODULE__{
            method: :get | :post | :put | :patch | :delete,
            url: String.t(),
            headers: list({String.t(), String.t()}),
            command: String.t() | nil,
            params: map
          }

    @spec build(atom, Core.Config.t(), binary, binary | nil) :: t()
    def build(
          method,
          %Core.Config{
            namespace: namespace,
            database: database,
            username: username,
            password: password,
            host: host
          },
          path
        ) do
      auth = :base64.encode("#{username}:#{password}")

      %__MODULE__{
        method: method,
        url: host <> path,
        headers: [
          {"Accept", "application/json"},
          {"NS", namespace},
          {"DB", database},
          {"Authorization", "Basic #{auth}"}
        ],
        command: nil,
        params: %{}
      }
    end

    def build(method, config, path, command) do
      %{build(method, config, path) | command: command}
    end

    @spec add_params(t, map) :: t
    def add_params(request, params) do
      %{request | params: params}
    end
  end

  @spec request(Core.HTTP.Request.t()) :: Core.Result.t()
  def request(%Core.HTTP.Request{
        method: method,
        url: url,
        headers: headers,
        command: command,
        params: params
      }) do
    request = %HTTPoison.Request{
      method: method,
      url: url,
      headers: headers,
      body: command || "",
      params: params || %{}
    }

    case HTTPoison.request(request) do
      {:ok, %{status_code: status, body: body}} ->
        case Jason.decode(body) do
          {:ok, data} ->
            if status === 200 do
              data
              |> Enum.map(fn value ->
                if(value["status"] == "OK",
                  do: {:ok, value["result"]},
                  else: {:error, value["detail"]}
                )
              end)
              |> List.flatten()
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
