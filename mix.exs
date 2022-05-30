defmodule DIN.MixProject do
  use Mix.Project

  def project do
    [
      app: :din,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      # Docs
      name: "DIN",
      source_url: "https://github.com/oliveigah/din",
      docs: [
        # The main page in the docs
        main: "DIN",
        extras: ["README.md"],
        groups_for_modules: [
          "Validation Protocols": [
            DIN.Validations.Protocols.Max,
            DIN.Validations.Protocols.Min
          ]
        ],
        groups_for_functions: [
          "Type functions": &(&1[:scope] == :type),
          "Validation functions": &(&1[:scope] == :validation)
        ]
      ]
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
      {:ex_doc, "~> 0.21", only: :docs}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
