defmodule Unreal.Core.Conn do
  @enforce_keys [:host]
  defstruct [:namespace, :database, :username, :password, :host]

  @type t :: %__MODULE__{
          namespace: String.t(),
          database: String.t(),
          username: String.t(),
          password: String.t(),
          host: String.t()
        }
end
