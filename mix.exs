defmodule InsightsScraper.MixProject do
  use Mix.Project

  def project do
    [
      app: :insights_scraper,
      version: "0.1.0",
      elixir: "~> 1.14-dev",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:neuron, "~> 5.0"},
      {:jason, "~> 1.0"},
      {:html_sanitize_ex, "~> 1.4"},
      {:nimble_csv, "~> 1.1"}
    ]
  end
end
