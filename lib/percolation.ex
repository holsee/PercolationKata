defmodule Percolation do
  use Application

  def permeable?(material) do
    Percolation.Percolator.permeable?(material)
  end

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(Percolation.Worker, [arg1, arg2, arg3])
      worker(Percolation.Percolator, []),
      supervisor(Percolation.CellSupervisor, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Percolation.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
