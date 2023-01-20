defmodule Unreal.Writer.Shared do
  @spec where(map, keyword) :: map
  def where(builder, matches) do
    {strings, params} =
      matches
      |> Enum.map(fn {key, rule} ->
        random_key = "k" <> (:crypto.strong_rand_bytes(4) |> Base.encode16())

        case rule do
          {:<=, value} -> {random_key, "#{key} <= $#{random_key}", value}
          {:>=, value} -> {random_key, "#{key} >= $#{random_key}", value}
          {:<, value} -> {random_key, "#{key} < $#{random_key}", value}
          {:>, value} -> {random_key, "#{key} > $#{random_key}", value}
          value -> {random_key, "#{key} = $#{random_key}", value}
        end
      end)
      |> Enum.reduce({[], %{}}, fn {key, string, value}, {strs, params} ->
        {strs ++ [string], params |> Map.put(key, value)}
      end)

    strings = strings |> Enum.join(" AND ")

    %{builder | where: strings, params: params}
  end
end
