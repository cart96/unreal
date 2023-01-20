defmodule Unreal.Writer.Count do
  @moduledoc """
  Query builder for counting.

    alias Unreal.Writer

    Writer.Count.init()
    |> Writer.Count.from("users")
    |> Writer.Count.where(age: {:>, 18})
    |> Writer.Count.build()

  Or

    alias Unreal.Writer

    Writer.Count.init("users", age: {:>, 18})
    |> Writer.Count.build()
  """

  defstruct [:from, :where, :params]

  @type t :: %__MODULE__{
          from: String.t(),
          where: String.t(),
          params: map
        }

  @spec init() :: t
  def init() do
    %__MODULE__{from: "", where: "", params: %{}}
  end

  @spec init(String.t()) :: t
  def init(table) do
    init()
    |> from(table)
  end

  @spec init(String.t(), keyword) :: t
  def init(table, matches) do
    init(table)
    |> where(matches)
  end

  @spec from(t, String.t()) :: t
  def from(builder, table) do
    %{builder | from: table}
  end

  @spec where(t, keyword) :: t
  def where(builder, matches) do
    Unreal.Writer.Shared.where(builder, matches)
  end

  @spec build(t) :: {String.t(), map}
  def build(%__MODULE__{from: from, where: where, params: params}) do
    if where == "" do
      {"SELECT count() FROM #{from} GROUP BY ALL;", params}
    else
      {"SELECT count() FROM #{from} WHERE #{where} GROUP BY ALL;", params}
    end
  end
end
