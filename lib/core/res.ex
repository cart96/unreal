defmodule Unreal.Core.Result do
  alias Unreal.Core

  @enforce_keys [:time, :status, :result, :detail]
  defstruct [:time, :status, :result, :detail]

  @type t :: %__MODULE__{
          time: String.t(),
          status: String.t(),
          result: map | list,
          detail: String.t()
        }

  @spec build(list) :: list(t)
  def build(value) when is_list(value) do
    value
    |> Enum.map(
      &%__MODULE__{
        time: &1["time"] || "",
        status: &1["status"] || "OK",
        result: &1["result"] || [],
        detail: &1["detail"] || ""
      }
    )
  end

  @spec build(nil) :: Core.Error.t()
  def build(value) when is_nil(value) do
    %Core.Error{
      code: 0,
      message: "Unexpected value 'nil'."
    }
  end

  @spec build(binary) :: list(t) | Core.Error.t()
  def build(raw) do
    case Jason.decode(raw) do
      {:ok, list} ->
        list
        |> Enum.map(
          &%__MODULE__{
            time: &1["time"] || "",
            status: &1["status"] || "OK",
            result: &1["result"] || [],
            detail: &1["detail"] || ""
          }
        )

      {:error, _} ->
        %Core.Error{
          code: 0,
          message: "Parsing error."
        }
    end
  end
end
