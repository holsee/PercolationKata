defmodule Percolation.PercolatorSupervisor do
	use Supervisor

  def start_link(ref) do
    Supervisor.start_link(__MODULE__, [ref])
  end

  def init([ref]) do
    children = [
      worker(Percolation.Percolator, [ref]),
      supervisor(Percolation.CellSupervisor, [])
    ]

    opts = [strategy: :one_for_one]
    supervise(children, opts)
  end
end
