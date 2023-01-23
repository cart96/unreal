defmodule Unreal.Writer.Delete do
  @moduledoc """
  Query builder for delete operation.

      alias Unreal.Writer

      Writer.Delete.init()
      |> Writer.Delete.from("users")
      |> Writer.Delete.where(age: {:<, 13})
      |> Writer.Delete.build()

  Or

      alias Unreal.Writer

      Writer.Delete.init("users", age: {:<, 13})
      |> Writer.Delete.build()
  """

  defstruct [:from, :where]

  @type t :: %__MODULE__{
          from: String.t(),
          where: keyword()
        }

  @spec init() :: t
  def init() do
    %__MODULE__{from: "", where: []}
  end

  @spec init(String.t()) :: t
  def init(table) do
    init()
    |> from(table)
  end

  @spec init(String.t(), keyword) :: t
  def init(record_name, data) do
    init(record_name)
    |> where(data)
  end

  @spec from(t, String.t()) :: t
  def from(builder, table) do
    %{builder | from: table}
  end

  @spec where(t, keyword) :: t
  def where(builder, data) do
    %{builder | where: data}
  end

  @spec build(t) :: {String.t(), map}
  def build(%__MODULE__{from: table, where: matches}) do
    {string, params} = Unreal.Writer.Shared.where(matches)
    {"DELETE #{table} WHERE #{string};", params}
  end
end
