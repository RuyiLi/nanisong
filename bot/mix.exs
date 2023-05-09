defmodule Bot.MixProject do
  use Mix.Project

  def project do
    [
      app: :app,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {MikuBeats.Application, []}
    ]
  end

  defp deps do
    [
      {:nostrum, github: "Kraigie/nostrum"},
      {:jason, "~> 1.4"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end
end
