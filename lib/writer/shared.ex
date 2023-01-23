defmodule Unreal.Writer.Shared do
  @moduledoc false

  @spec where(keyword, String.t()) :: {String.t(), map}
  def where(matches, join \\ " AND ") do
    {strings, params} =
      matches
      |> Enum.map(fn {key, rule} ->
        random_key = Atom.to_string(key) <> (:crypto.strong_rand_bytes(4) |> Base.encode16())

        case rule do
          {:<=, value} -> {random_key, "#{key} <= $#{random_key}", value}
          {:>=, value} -> {random_key, "#{key} >= $#{random_key}", value}
          {:<, value} -> {random_key, "#{key} < $#{random_key}", value}
          {:>, value} -> {random_key, "#{key} > $#{random_key}", value}
          {:+, value} -> {random_key, "#{key} += $#{random_key}", value}
          {:-, value} -> {random_key, "#{key} -= $#{random_key}", value}
          value -> {random_key, "#{key} = $#{random_key}", value}
        end
      end)
      |> Enum.reduce({[], %{}}, fn {key, string, value}, {strs, params} ->
        {[string | strs], params |> Map.put(key, value)}
      end)

    strings = strings |> Enum.join(join)

    {strings, params}
  end
end
