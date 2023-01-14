defmodule Unreal.Core.HTTP do
  @spec request(Unreal.Core.Request.t()) ::
          [Unreal.Core.Result.t()] | {:error, :connection_error | :invalid_json}
  def request(%Unreal.Core.Request{url: url, headers: headers, sql: sql}) do
    case HTTPoison.post(url, sql, headers) do
      {:ok, %{body: body}} ->
        Unreal.Core.Result.build(body)

      {:error, _} ->
        {:error, :connection_error}
    end
  end
end
