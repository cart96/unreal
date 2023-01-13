defmodule Unreal.Core.Conn do
  @enforce_keys [:namespace, :database, :user, :password, :host]
  defstruct [:namespace, :database, :user, :password, :host]
end
