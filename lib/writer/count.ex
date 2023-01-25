defmodule Unreal.Writer.Count do
  @moduledoc """
  Query builder for count operation.

      alias Unreal.Writer

      Writer.Count.init()
      |> Writer.Count.from("users")
      |> Writer.Count.where(age: {:gt, 18})
      |> Writer.Count.build()

  Or

      alias Unreal.Writer

      Writer.Count.init("users", age: {:gt, 18})
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
    {string, params} = Unreal.Writer.Shared.where(matches)
    %{builder | where: string, params: params}
  end

  @spec build(t) :: {String.t(), map}
  def build(%__MODULE__{from: from, where: where, params: params}) do
    if where == "" do
      {"SELECT count() AS total FROM #{from} GROUP BY total;", params}
    else
      {"SELECT count() AS total FROM #{from} WHERE #{where} GROUP BY total;", params}
    end
  end
end
