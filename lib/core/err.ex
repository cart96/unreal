defmodule Unreal.Core.Error do
  @enforce_keys [:code, :message]
  defstruct [:code, :message]

  @type t :: %__MODULE__{
          code: integer(),
          message: String.t()
        }

  @spec build(binary) :: t
  def build(raw) do
    case Jason.decode(raw) do
      {:ok, result} ->
        %__MODULE__{
          code: result["code"] || 0,
          message: result["information"] || result["description"] || result["details"] || ""
        }

      {:error, _} ->
        %__MODULE__{
          code: 0,
          message: "Parsing error."
        }
    end
  end
end
