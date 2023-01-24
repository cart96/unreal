defmodule Unreal.Core.Result do
  @moduledoc """
  Action result.
  """

  @type t :: {:ok, any} | {:error, String.t()} | list(t)

  @spec build(any) :: t
  def build([value]) when is_list(value) do
    {:ok, value}
  end

  def build(value) when is_map(value) or is_list(value) do
    {:ok, value}
  end

  def build(value) when is_boolean(value) do
    if value do
      {:ok, nil}
    else
      {:error, "unknown error returned from response"}
    end
  end

  def build(raw) when is_binary(raw) do
    case Jason.decode(raw) do
      {:ok, value} ->
        build(value)

      {:error, _} ->
        if raw == "" do
          {:ok, nil}
        else
          {:error, "parsing error"}
        end
    end
  end

  def build(_value) do
    {:ok, nil}
  end
end
