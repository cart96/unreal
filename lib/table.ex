defmodule Unreal.Table do
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
