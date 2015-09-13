defmodule Percolation.Percolator do
  use GenServer
  alias __MODULE__
  defstruct ref: nil, from: nil, rows: []

  def permeable?(ref, material) do
    GenServer.call name(ref), {:test_material, material}
  end

  def start_link(ref) do
    GenServer.start_link __MODULE__, [ref], name: name(ref)
  end

  def init([ref]) do
    {:ok, %Percolator{ref: ref}}
  end

  def handle_call({:test_material, material}, from, state) do
    state = %{state | rows: setup_cells(state.ref, material) }
    state = %{state | from: from}
    GenServer.cast name(state.ref), :run
    {:noreply, state}
  end

  def handle_cast(:run, state) do
    # tell each cell to find out from it's neighbours if it's blocked
    Enum.each(state.rows, fn(row_contents) ->
      row_contents |> Enum.each(fn({_, pid} = _cell) ->
        Percolation.Cell.calculate_status(pid)
      end)
    end)
    {:noreply, state}
  end

  def handle_cast({:update_status, row, column, status}, state) do
    rows = List.update_at(state.rows, row, fn(row_contents) ->
      List.update_at(row_contents, column, fn({_, pid}) ->
        {status, pid}
      end)
    end)
    state = %{state | rows: rows}
    check(state)
    {:noreply, state}
  end

  defp setup_cells(ref, material) do
    material |> Enum.with_index |> Enum.map(fn({row_contents, row}) ->
      row_contents |> Enum.with_index |> Enum.map(fn({cell, column}) ->
        cell_content = case cell do
          1 -> :solid
          0 -> :space
        end
        {:ok, pid} = Percolation.CellSupervisor.add_cell(ref, self, row, column, cell_content)
        {:unknown, pid}
      end)
    end)
  end

  def check(state) do
    if complete?(state.rows) do
      permeable = is_permeable?(state.rows)
      GenServer.reply(state.from, permeable)
    end
  end

  defp complete?(rows) do
    Enum.all? rows, fn(row_contents) ->
      Enum.all? row_contents, fn({status, _}) ->
        status != :unknown
      end
    end
  end

  def is_permeable?(rows) do
    Enum.all? rows, fn(row_contents) ->
      Enum.any? row_contents, fn({status, _}) ->
        status == :open
      end
    end
  end

  defp name(ref), do: :"percolator_#{inspect ref}"
end
