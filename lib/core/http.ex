defmodule Unreal.Core.HTTP do
  def request(%Unreal.Core.Req{url: url, headers: headers, sql: sql}) do
    HTTPoison.post(url, sql, headers)
  end
end
