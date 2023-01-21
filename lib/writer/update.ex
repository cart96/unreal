defmodule Unreal.Writer.Update do
  @moduledoc """
  Query builder for update operation.

    alias Unreal.Writer

    Writer.Update.init()
    |> Writer.Update.name("users")
    |> Writer.Update.values(point: {:+, 10}, verified: true)
    |> Writer.Update.where(point: {:>, 50})
    |> Writer.Update.build()

  Or

    alias Unreal.Writer

    Writer.Update.init("users", [point: {:+, 10}, verified: true], point: {:>, 50})
    |> Writer.Update.build()
  """

  defstruct [:name, :values, :where]

  @type t :: %__MODULE__{
          name: String.t(),
          values: keyword(),
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

  @spec init(String.t(), keyword, keyword) :: t
  def init(record_name, data, matches) do
    init(record_name, data)
    |> where(matches)
  end

  @spec name(t, String.t()) :: t
  def name(builder, record_name) do
    %{builder | name: record_name}
  end

  @spec values(t, keyword) :: t
  def values(builder, data) do
    %{builder | values: data}
  end

  @spec where(t, keyword) :: t
  def where(builder, matches) do
    %{builder | where: matches}
  end

  @spec build(t) :: {String.t(), map}
  def build(%__MODULE__{name: name, values: values, where: where}) do
    {set_string, set_params} = Unreal.Writer.Shared.where(values, ", ")
    {where_string, where_params} = Unreal.Writer.Shared.where(where)

    if where_params == %{} do
      {"UPDATE #{name} SET #{set_string};", set_params}
    else
      {"UPDATE #{name} SET #{set_string} WHERE #{where_string};",
       Map.merge(set_params, where_params)}
    end
  end
end
