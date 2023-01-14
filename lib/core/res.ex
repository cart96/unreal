defmodule Unreal.Core.Result do
  alias Unreal.Core

  @enforce_keys [:time, :status, :result]
  defstruct [:time, :status, :result]

  @type t :: %__MODULE__{
          time: String.t(),
          status: String.t(),
          result: map | list
        }

  @spec build(binary) :: list(t) | Core.Error.t()
  def build(raw) do
    case Jason.decode(raw) do
      {:ok, list} ->
        list
        |> Enum.map(
          &%__MODULE__{
            time: &1["time"] || "",
            status: &1["status"] || "OK",
            result: &1["result"] || []
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
