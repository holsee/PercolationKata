defmodule Percolation do
  use Application

  def permeable?(material) do
    ref = make_ref
    {:ok, pid} = Supervisor.start_child(Percolation.Supervisor, [ref])
    permeable = Percolation.Percolator.permeable?(ref, material)
    :ok = Supervisor.terminate_child(Percolation.Supervisor, pid)
    permeable
  end

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Percolation.PercolatorSupervisor, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :simple_one_for_one, name: Percolation.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
