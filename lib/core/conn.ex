defmodule Unreal.Core.Conn do
  @enforce_keys [:namespace, :database, :user, :password, :host]
  defstruct [:namespace, :database, :user, :password, :host]

  @type t :: %__MODULE__{
          namespace: String.t(),
          database: String.t(),
          user: String.t(),
          password: String.t(),
          host: String.t()
        }
end
