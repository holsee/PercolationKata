defmodule Percolation.Cell do
  use GenServer
  alias __MODULE__
  defstruct percolator: nil,
            ref: nil,
            row_index: nil,
            cell_index: nil,
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

  def start_link(ref, percolator, row_index, cell_index, cell_content) do
    name = cell_name(ref, row_index, cell_index)
    GenServer.start_link(__MODULE__, [ref, percolator, row_index, cell_index, cell_content], name: name)
  end

  def init([ref, percolator, row_index, cell_index, cell_content]) do
    state = %Cell{
      percolator: percolator,
      ref: ref,
      row_index: row_index,
      cell_index: cell_index,
      cell_content: cell_content,
      left_cell: left_cell_state(cell_index),
      right_cell: right_cell_state(cell_index),
      above_cell: above_cell_state(row_index),
      blocked: blocked_state(cell_content)
    }

    {:ok, state}
  end

  def handle_cast(:calculate_status, %{cell_content: :solid} = state) do
    GenServer.cast(state.percolator, {:update_status, state.row_index, state.cell_index, :blocked})
    {:noreply, state}
  end
  def handle_cast(:calculate_status, state) do
    # ask left, right, and top neighbours to tell this cell what they contain
    if state.row_index > 0 do
      cell_open?(self, cell_name(state.ref, state.row_index - 1, state.cell_index))
    end
    if state.cell_index > 0 do
      cell_open?(self, cell_name(state.ref, state.row_index, state.cell_index - 1))
    end
    if state.cell_index < 4 do
      cell_open?(self, cell_name(state.ref, state.row_index, state.cell_index + 1))
    end
    {:noreply, state}
  end

  def handle_cast({:is_cell_open, from}, state) do
    cell_open = case state.cell_content do
      :space -> :open
      :solid -> :blocked
    end
    GenServer.cast(from, {:is_cell_open_reply, state.row_index, state.cell_index, cell_open})
    {:noreply, state}
  end

  def handle_cast({:is_cell_open_reply, neighbour_row, neighbour_cell, cell_open}, %{row_index: row_index, cell_index: cell_index} = state) do
    state = case cell_open do
      cell_open when neighbour_row == row_index - 1 and neighbour_cell == cell_index ->
        %{state | above_cell: cell_open}
      cell_open when neighbour_row == row_index and neighbour_cell == cell_index - 1 ->
        %{state | left_cell: cell_open}
      cell_open when neighbour_row == row_index and neighbour_cell == cell_index + 1 ->
        %{state | right_cell: cell_open}
    end
    reply_to_percolator(state)
    {:noreply, state}
  end

  defp reply_to_percolator(%{left_cell: :blocked, right_cell: :blocked, above_cell: :blocked} = state) do
    GenServer.cast(state.percolator, {:update_status, state.row_index, state.cell_index, :blocked})
  end
  defp reply_to_percolator(%{left_cell: left_cell, right_cell: right_cell, above_cell: above_cell} = state)
    when left_cell == :open or right_cell == :open or above_cell == :open do
    GenServer.cast(state.percolator, {:update_status, state.row_index, state.cell_index, :open})
  end
  defp reply_to_percolator(_state) do
    # don't know enough to reply yet so do nothing
  end

  defp cell_name(ref, row_index, cell_index), do: :"#{inspect ref}_cell_#{row_index}_#{cell_index}"

  defp left_cell_state(_cell_index = 0), do: :blocked
  defp left_cell_state(_), do: :unknown

  defp right_cell_state(_cell_index = 5), do: :blocked
  defp right_cell_state(_), do: :unknown

  defp above_cell_state(_row_index = 0), do: :open
  defp above_cell_state(_), do: :unknown

  defp blocked_state(:solid), do: true
  defp blocked_state(:space), do: :unknown
end
