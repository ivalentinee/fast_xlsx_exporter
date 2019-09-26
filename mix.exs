defmodule FastXlsxExporter.MixProject do
  use Mix.Project

  def project do
    [
      app: :fast_xlsx_exporter,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: []
    ]
  end

  def application do
    [
      extra_applications: []
    ]
  end
end
