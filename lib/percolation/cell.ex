defmodule Percolation.Cell do
  use GenServer
  alias __MODULE__
  defstruct percolator: nil,
            ref: nil,
            row: nil,
            column: nil,
            cell_content: nil,
            left_cell: nil,
            right_cell: nil,
            above_cell: nil,
            blocked: nil

  def calculate_status(cell) do
    GenServer.cast cell, :calculate_status
  end

  def cell_open?(from, target_cell_name) do
    GenServer.cast(target_cell_name, {:is_cell_open, from})
  end

  def start_link(ref, percolator, row, column, cell_content) do
    name = cell_name(ref, row, column)
    GenServer.start_link(__MODULE__, [ref, percolator, row, column, cell_content], name: name)
  end

  def init([ref, percolator, row, column, cell_content]) do
    state = %Cell{
      percolator: percolator,
      ref: ref,
      row: row,
      column: column,
      cell_content: cell_content,
      left_cell: left_cell_state(column),
      right_cell: right_cell_state(column),
      above_cell: above_cell_state(row),
      blocked: blocked_state(cell_content)
    }

    {:ok, state}
  end

  def handle_cast(:calculate_status, %{cell_content: :solid} = state) do
    GenServer.cast(state.percolator, {:update_status, state.row, state.column, :blocked})
    {:noreply, state}
  end
  def handle_cast(:calculate_status, state) do
    # ask left, right, and top neighbours to tell this cell what they contain
    if state.row > 0 do
      cell_open?(self, cell_name(state.ref, state.row - 1, state.column))
    end
    if state.column > 0 do
      cell_open?(self, cell_name(state.ref, state.row, state.column - 1))
    end
    if state.column < 4 do
      cell_open?(self, cell_name(state.ref, state.row, state.column + 1))
    end
    {:noreply, state}
  end

  def handle_cast({:is_cell_open, from}, state) do
    cell_open = case state.cell_content do
      :space -> :open
      :solid -> :blocked
    end
    GenServer.cast(from, {:is_cell_open_reply, state.row, state.column, cell_open})
    {:noreply, state}
  end

  def handle_cast({:is_cell_open_reply, neighbour_row, neighbour_cell, cell_open}, %{row: row, column: column} = state) do
    state = case cell_open do
      cell_open when neighbour_row == row - 1 and neighbour_cell == column ->
        %{state | above_cell: cell_open}
      cell_open when neighbour_row == row and neighbour_cell == column - 1 ->
        %{state | left_cell: cell_open}
      cell_open when neighbour_row == row and neighbour_cell == column + 1 ->
        %{state | right_cell: cell_open}
    end
    state = reply_to_percolator(state)
    {:noreply, state}
  end

  # if we've set blocked to true or false we've notified the percolator and don't need to do anything else
  defp reply_to_percolator(%{blocked: blocked} = state) when blocked != :unknown, do: state
  defp reply_to_percolator(%{left_cell: :blocked, right_cell: :blocked, above_cell: :blocked} = state) do
    GenServer.cast(state.percolator, {:update_status, state.row, state.column, :blocked})
    %{state | blocked: true}
  end
  defp reply_to_percolator(%{left_cell: left_cell, right_cell: right_cell, above_cell: above_cell} = state)
    when left_cell == :open or right_cell == :open or above_cell == :open do
    GenServer.cast(state.percolator, {:update_status, state.row, state.column, :open})
    %{state | blocked: false}
  end
  # don't know enough to reply yet so do nothing
  defp reply_to_percolator(state), do: state

  defp cell_name(ref, row, column), do: :"#{inspect ref}_cell_#{row}_#{column}"

  defp left_cell_state(_column = 0), do: :blocked
  defp left_cell_state(_), do: :unknown

  defp right_cell_state(_column = 5), do: :blocked
  defp right_cell_state(_), do: :unknown

  defp above_cell_state(_row = 0), do: :open
  defp above_cell_state(_), do: :unknown

  defp blocked_state(:solid), do: true
  defp blocked_state(:space), do: :unknown
end
