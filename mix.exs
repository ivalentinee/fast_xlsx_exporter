defmodule FastXlsxExporter.MixProject do
  use Mix.Project

  def project do
    [
      app: :fast_xlsx_exporter,
      version: "0.1.3",
      elixir: "~> 1.8",
      description: "Fast xlsx table exporter",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: docs(),
      elixirc_paths: elixirc_paths(Mix.env()),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/ivalentinee/fast_xlsx_exporter"}
    ]
  end

  defp docs do
    [
      main: "FastXlsxExporter",
      source_url: "https://github.com/ivalentinee/fast_xlsx_exporter"
    ]
  end

  def application do
    [
      extra_applications: []
    ]
  end

  def deps do
    [
      {:xlsxir, "~> 1.6.4", only: [:dev, :test], optional: true, runtime: false},
      {:credo, "~> 1.3", only: [:dev, :test], optional: true, runtime: false},
      {:excoveralls, "~> 0.10", only: :test, optional: true},
      {:ex_doc, "~> 0.21", only: :dev, optional: true, runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
