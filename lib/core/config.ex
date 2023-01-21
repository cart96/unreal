defmodule Unreal.Core.Config do
  @moduledoc """
  Config for connection. Field names are pretty much self explanatory.

  ## Options
  - timeout: Allows you to set custom timeout, default is `5000`. If you want to remove timeout, put `:infinity` instead.
  """
  @enforce_keys [:host]
  defstruct [:namespace, :database, :username, :password, :host, :options]

  @type t :: %__MODULE__{
          namespace: String.t(),
          database: String.t(),
          username: String.t(),
          password: String.t(),
          host: String.t(),
          options: keyword()
        }
end
