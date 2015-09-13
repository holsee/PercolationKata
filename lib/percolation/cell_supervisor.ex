defmodule Percolation.CellSupervisor do
  use Supervisor

  def add_cell(percolator, row_index, cell_index, cell_content) do
    Supervisor.start_child(__MODULE__, [percolator, row_index, cell_index, cell_content])
  end

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    children = [
      worker(Percolation.Cell, [])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
