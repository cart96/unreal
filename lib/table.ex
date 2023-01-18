defmodule Unreal.Table do
  @moduledoc """
  This macro allows you to use a table directly. Adds `&insert/2`, `&update/2`, `&get/1`, `&change/2`, `&modify/2` and `&delete/1` functions.

      defmodule Users do
        # name: the name of the connection
        # table: table to use
        use Unreal.Table, name: :database, table: "users"
      end

      Users.get("bob")
  """
  defmacro __using__(name: name, table: table) do
    quote bind_quoted: [name: name, table: table] do
      def insert(id, data) do
        Unreal.insert(unquote(name), unquote(table), id, data)
      end

      def get(id) do
        Unreal.get(unquote(name), unquote(table), id)
      end

      def update(id, data) do
        Unreal.update(unquote(name), unquote(table), id, data)
      end

      def change(id, data) do
        Unreal.change(unquote(name), unquote(table), id, data)
      end

      def modify(id, data) do
        Unreal.modify(unquote(name), unquote(table), id, data)
      end

      def delete(id) do
        Unreal.delete(unquote(name), unquote(table), id)
      end
    end
  end
end
