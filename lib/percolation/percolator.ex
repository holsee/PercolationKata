defmodule Percolation.Percolator do
  use GenServer
  alias __MODULE__
  defstruct rows: [], from: nil

  def permeable?(material) do
    GenServer.call __MODULE__, {:test_material, material}
  end

  def start_link do
    GenServer.start_link __MODULE__, [], name: __MODULE__
  end

  def init([]) do
    {:ok, %Percolator{}}
  end

  def handle_call({:test_material, material}, from, state) do
    state = %{state | rows: setup_cells(material) }
    state = %{state | from: from}
    GenServer.cast __MODULE__, :run
    {:noreply, state}
  end

  def handle_cast(:run, state) do
    # tell each cell to find out from it's neighbours if it's blocked
    Enum.each(state.rows, fn(row) ->
      row |> Enum.each(fn({_, pid} = _cell) ->
        Percolation.Cell.calculate_status(pid)
      end)
    end)
    {:noreply, state}
  end

  def handle_cast({:update_status, row, column, status}, state) do
    rows = List.update_at(state.rows, row, fn(row) ->
      List.update_at(row, column, fn({_, pid}) ->
        {status, pid}
      end)
    end)
    state = %{state | rows: rows}
    check(state)
    {:noreply, state}
  end

  defp setup_cells(material) do
    material |> Enum.with_index |> Enum.map(fn({row, row_index}) ->
      row |> Enum.with_index |> Enum.map(fn({cell, cell_index}) ->
        cell_content = case cell do
          1 -> :solid
          0 -> :space
        end
        {:ok, pid} = Percolation.CellSupervisor.add_cell(self, row_index, cell_index, cell_content)
        {:unknown, pid}
      end)
    end)
  end

  def check(state) do
    if complete?(state.rows) do
      permeable = is_permeable?(state.rows)
      finished(state.rows)
      GenServer.reply(state.from, permeable)
    end
  end

  defp complete?(rows) do
    Enum.all? rows, fn(row) ->
      Enum.all? row, fn({status, _}) ->
        status != :unknown
      end
    end
  end

  def is_permeable?(rows) do
    Enum.all? rows, fn(row) ->
      Enum.any? row, fn({status, _}) ->
        status == :open
      end
    end
  end

  defp finished(rows) do
    Enum.each rows, fn(row) ->
      Enum.each row, fn({_, pid}) ->
        :ok = Supervisor.terminate_child(Percolation.CellSupervisor, pid)
      end
    end
  end
end
