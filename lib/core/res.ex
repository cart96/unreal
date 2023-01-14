defmodule Unreal.Core.Result do
  @enforce_keys [:time, :status, :result]
  defstruct [:time, :status, :result]

  @type t :: %__MODULE__{
          time: String.t(),
          status: String.t(),
          result: map | list
        }

  @spec build(binary) :: list(t) | {:error, :invalid_json}
  def build(raw) do
    case Jason.decode(raw) do
      {:ok, list} ->
        list
        |> Enum.map(&%__MODULE__{time: &1["time"], status: &1["status"], result: &1["result"]})

      {:error, _} ->
        {:error, :invalid_json}
    end
  end
end
