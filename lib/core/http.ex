defmodule Unreal.Core.HTTP do
  alias Unreal.Core

  @spec request(Core.Request.t()) ::
          [Core.Result.t()] | {:error, :connection_error | :invalid_json}
  def request(%Core.Request{method: :post, url: url, headers: headers, command: command}) do
    case HTTPoison.post(url, command, headers) do
      {:ok, %{body: body}} ->
        Core.Result.build(body)

      {:error, _} ->
        {:error, :connection_error}
    end
  end

  def request(%Core.Request{method: :get, url: url, headers: headers}) do
    case HTTPoison.get(url, headers) do
      {:ok, %{body: body}} ->
        Core.Result.build(body)

      {:error, _} ->
        {:error, :connection_error}
    end
  end

  def request(%Core.Request{method: :put, url: url, headers: headers, command: command}) do
    case HTTPoison.put(url, command, headers) do
      {:ok, %{body: body}} ->
        Core.Result.build(body)

      {:error, _} ->
        {:error, :connection_error}
    end
  end

  def request(%Core.Request{method: :patch, url: url, headers: headers, command: command}) do
    case HTTPoison.patch(url, command, headers) do
      {:ok, %{body: body}} ->
        Core.Result.build(body)

      {:error, _} ->
        {:error, :connection_error}
    end
  end

  def request(%Core.Request{method: :delete, url: url, headers: headers}) do
    case HTTPoison.delete(url, headers) do
      {:ok, %{body: body}} ->
        Core.Result.build(body)

      {:error, _} ->
        {:error, :connection_error}
    end
  end
end
