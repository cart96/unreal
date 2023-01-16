defmodule Unreal.Table do
  defmacro __using__(name: name, table: table) do
    quote bind_quoted: [name: name, table: table] do
      def insert(id, data) do
        if Keyword.has_key?(__MODULE__.__info__(:functions), :changeset) do
          changeset = apply(__MODULE__, :changeset, [%__MODULE__{}, data])

          if changeset.valid? do
            Unreal.insert(unquote(name), unquote(table), id, data)
          else
            {:error, {:ecto, changeset}}
          end
        else
          Unreal.insert(unquote(name), unquote(table), id, data)
        end
      end

      def get(id) do
        Unreal.get(unquote(name), unquote(table), id)
      end

      def patch(id, data) do
        Unreal.patch(unquote(name), unquote(table), id, data)
      end

      def update(id, data) do
        if Keyword.has_key?(__MODULE__.__info__(:functions), :changeset) do
          changeset = apply(__MODULE__, :changeset, [%__MODULE__{}, data])

          if changeset.valid? do
            Unreal.update(unquote(name), unquote(table), id, data)
          else
            {:error, {:ecto, changeset}}
          end
        else
          Unreal.update(unquote(name), unquote(table), id, data)
        end
      end

      def delete(id) do
        Unreal.delete(unquote(name), unquote(table), id)
      end
    end
  end
end
