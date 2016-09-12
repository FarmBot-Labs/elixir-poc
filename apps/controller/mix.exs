defmodule Controller.Mixfile do
  use Mix.Project

  def project do
    [app: :controller,
     version: "0.1.0",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [mod: {Controller, []},
      applications: [:logger, :nerves_uart, :httpotion, :poison, :gen_stage, :bus, :nerves_lib]]
  end

  defp deps do
    [{:nerves_uart, "~> 0.1.0"},
     {:httpotion, "~> 3.0.0"},
     {:poison, "~> 2.0"},
     {:bus, "~> 0.1.0"},
     {:gen_stage, "~> 0.4"},
     {:nerves_lib, github: "nerves-project/nerves_lib"}]
  end
end
