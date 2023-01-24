defmodule Unreal.Core.Result do
  @moduledoc """
  Action result.
  """

  @type t :: {:ok, any} | {:error, String.t()} | list(t)

  @spec build(any) :: t
  def build([value]) do
    {:ok, value}
  end

  def build([]) do
    {:ok, nil}
  end

  def build("") do
    {:ok, nil}
  end

  def build(true) do
    {:ok, nil}
  end

  def build(false) do
    {:error, "unknown error returned from response"}
  end

  def build(value) when is_map(value) or is_list(value) do
    {:ok, value}
  end

  def build(raw) when is_binary(raw) do
    case Jason.decode(raw) do
      {:ok, value} ->
        build(value)

      {:error, _} ->
        {:error, "parsing error"}
    end
  end

  def build(_value) do
    {:ok, nil}
  end
end
