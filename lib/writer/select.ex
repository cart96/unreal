defmodule Unreal.Writer.Select do
  @moduledoc """
  Query builder for select operation.

    alias Unreal.Writer

    Writer.Select.init()
    |> Writer.Select.from("users")
    |> Writer.Select.where(age: {:>, 18})
    |> Writer.Select.get([:username, :age])
    |> Writer.Select.build()

  Or

    alias Unreal.Writer

    Writer.Select.init("users", [:username, :age], age: {:>, 18})
    |> Writer.Select.build()
  """

  defstruct [:values, :from, :where, :params]

  @type t :: %__MODULE__{
          values: String.t(),
          from: String.t(),
          where: String.t(),
          params: map
        }

  @spec init() :: t
  def init() do
    %__MODULE__{values: "*", from: "", where: "", params: %{}}
  end

  @spec init(String.t()) :: t
  def init(table) do
    init()
    |> from(table)
  end

  @spec init(String.t(), String.t() | list(atom)) :: t
  def init(table, values) do
    init(table)
    |> get(values)
  end

  @spec init(String.t(), String.t() | list(atom), keyword) :: t
  def init(table, values, matches) do
    init(table, values)
    |> where(matches)
  end

  @spec get(t, any) :: t
  def get(builder, values) when is_list(values) do
    %{builder | values: values |> Enum.map(&Atom.to_string/1) |> Enum.join(", ")}
  end

  def get(builder, raw) do
    %{builder | values: to_string(raw)}
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
  def build(%__MODULE__{values: values, from: from, where: where, params: params}) do
    if where == "" do
      {"SELECT #{values} FROM #{from};", %{}}
    else
      {"SELECT #{values} FROM #{from} WHERE #{where};", params}
    end
  end
end
