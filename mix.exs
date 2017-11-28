defmodule Client.Mixfile do
  use Mix.Project

  def project do
    [
      app: :client,
      version: "0.1.0",
      elixir: "~> 1.5",
      # escript: escript(),                        
      start_permanent: Mix.env == :prod,
      deps: deps(),
      emu_args: [ "+P 5000000" ],
      escript: [
        main_module: App,
        emu_args: [ "+P 5000000" ],
      ]
    ]
  end

  # def escript() do
  #   [main_module: App]
  # end
  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: { Client, [] },
      extra_applications: [:logger, :gproc]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:gproc, "0.3.1"}      
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
