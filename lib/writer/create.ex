defmodule Unreal.Writer.Create do
  @moduledoc """
  Query builder for create operation.

    alias Unreal.Writer

    Writer.Create.init()
    |> Writer.Create.name("users:bob")
    |> Writer.Create.values(age: 18, verified: true)
    |> Writer.Create.build()

  Or

    alias Unreal.Writer

    Writer.Create.init("users:bob", age: 18, verified: true)
    |> Writer.Create.build()
  """

  defstruct [:name, :values]

  @type t :: %__MODULE__{
          name: String.t(),
          values: keyword()
        }

  @spec init() :: t
  def init() do
    %__MODULE__{name: "", values: []}
  end

  @spec init(String.t()) :: t
  def init(record_name) do
    init()
    |> name(record_name)
  end

  @spec init(String.t(), keyword) :: t
  def init(record_name, data) do
    init(record_name)
    |> values(data)
  end

  @spec name(t, String.t()) :: t
  def name(builder, record_name) do
    %{builder | name: record_name}
  end

  @spec values(t, keyword) :: t
  def values(builder, data) do
    %{builder | values: data}
  end

  @spec build(t) :: {String.t(), map}
  def build(%__MODULE__{name: name, values: values}) do
    {string, params} = Unreal.Writer.Shared.where(values, ", ")
    {"CREATE #{name} SET #{string};", params}
  end
end
