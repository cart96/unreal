defmodule Unreal.MixProject do
  use Mix.Project

  def project do
    [
      app: :unreal,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.8"},
      {:jason, ">= 1.0.0"},
      {:socket, "~> 0.3"}
    ]
  end
end
