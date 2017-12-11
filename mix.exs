defmodule BggXmlApi2.Mixfile do
  use Mix.Project

  def project do
    [
      app: :bgg_xml_api2,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:sweet_xml, "~> 0.6.5"},
      {:httpoison, "~> 0.13.0"}
    ]
  end
end
