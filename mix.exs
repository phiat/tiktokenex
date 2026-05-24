defmodule Tiktokenex.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/phiat/tiktokenex"

  def project do
    [
      app: :tiktokenex,
      version: @version,
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      name: "Tiktokenex",
      source_url: @source_url
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Tiktokenex.Application, []}
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  defp description do
    "Pure Elixir BPE tokenizer compatible with OpenAI's tiktoken. " <>
      "Supports cl100k_base (GPT-4, GPT-3.5) and o200k_base (GPT-4o) encodings. " <>
      "No NIFs, no Python, no external dependencies."
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      files: ~w(lib mix.exs README.md LICENSE .formatter.exs)
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "LICENSE"],
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end
end
