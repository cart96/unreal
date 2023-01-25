defmodule Unreal.Core.HTTP do
  @moduledoc false

  alias Unreal.Core

  defmodule Request do
    @moduledoc false

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

  @spec request(Core.HTTP.Request.t(), keyword) :: Core.Result.t()
  def request(
        %Core.HTTP.Request{
          method: method,
          url: url,
          headers: headers,
          command: command,
          params: params
        },
        options
      ) do
    %HTTPoison.Request{
      method: method,
      url: url,
      headers: headers,
      body: command || "",
      params: params || %{},
      options: [recv_timeout: options[:timeout] || 5000]
    }
    |> HTTPoison.request()
    |> handle_response_result()
  end

  defp handle_response_result({:error, _}) do
    {:error, "http connection error"}
  end

  defp handle_response_result({:ok, %{body: body}}) do
    body
    |> Jason.decode()
    |> handle_response_body()
  end

  defp handle_response_body({:error, _data}) do
    {:error, "http body parse error"}
  end

  defp handle_response_body({:ok, %{"status" => "OK", "result" => result}}) do
    {:ok, Core.Utils.get_first(result)}
  end

  defp handle_response_body({:ok, %{"status" => "ERR", "details" => details}}) do
    {:error, details}
  end

  defp handle_response_body({:ok, data}) when is_list(data) do
    data
    |> Enum.map(&handle_response_body({:ok, &1}))
    |> Core.Utils.get_first()
  end

  defp handle_response_body({:ok, data}) do
    {:error, data["information"] || data["description"] || data["details"]}
  end
end
