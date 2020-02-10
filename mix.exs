defmodule FastXlsxExporter.MixProject do
  use Mix.Project

  def project do
    [
      app: :fast_xlsx_exporter,
      version: "0.1.0",
      elixir: "~> 1.8",
      description: "Fast xlsx table exporter",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: docs()
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
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end
end
