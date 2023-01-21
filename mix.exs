defmodule Unreal.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/cart96/unreal"

  def project do
    [
      app: :unreal,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),

      # documentation
      name: "Unreal",
      source_url: @source_url,
      docs: [
        logo: "./assets/unreal.png",
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.4"},
      {:socket, "~> 0.3.13"},
      {:ex_doc, "~> 0.29.1", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "Unofficial SurrealDB client for Elixir"
  end

  defp package() do
    [
      name: "unreal",
      licenses: ["MIT License"],
      links: %{"GitHub" => @source_url},
      maintainers: ["icecat696 (cart96)"]
    ]
  end
end
