defmodule Percolation.PercolatorSupervisor do
	use Supervisor

  def start_link(ref) do
    Supervisor.start_link(__MODULE__, [ref], name: name(ref))
  end

  def init([ref]) do
    children = [
      worker(Percolation.Percolator, [ref]),
      supervisor(Percolation.CellSupervisor, [ref])
    ]

    opts = [strategy: :one_for_one]
    supervise(children, opts)
  end

  defp name(ref), do: :"percolator_supervisor_#{inspect ref}"
end
