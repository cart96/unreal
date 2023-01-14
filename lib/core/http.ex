defmodule Unreal.Core.HTTP do
  alias Unreal.Core

  @spec request(Core.Request.t()) :: list(Core.Result.t()) | Core.Error.t()
  def request(%Core.Request{method: method, url: url, headers: headers, command: command}) do
    request = %HTTPoison.Request{
      method: method,
      url: url,
      headers: headers,
      body: command || ""
    }

    case HTTPoison.request(request) do
      {:ok, %{status_code: status, body: body}} ->
        if status === 200 do
          Core.Result.build(body)
        else
          Core.Error.build(body)
        end

      {:error, _} ->
        %Core.Error{
          code: 0,
          message: "Connection error."
        }
    end
  end
end
