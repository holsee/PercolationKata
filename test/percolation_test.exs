defmodule PercolationTest do
  use ExUnit.Case

  test "returns true when there's a path through the material" do
    material = [
      [1, 0, 1, 1, 0],
      [1, 0, 0, 1, 1],
      [1, 1, 0, 1, 1],
      [1, 0, 0, 1, 1],
      [1, 0, 1, 1, 1]
    ]
    assert Percolation.permeable?(material)
  end

  test "returns false when there's isn't a path through the material" do
    material = [
      [1, 0, 1, 1, 0],
      [1, 1, 0, 1, 1],
      [1, 1, 0, 1, 1],
      [1, 0, 0, 1, 1],
      [1, 0, 1, 1, 1]
    ]
    refute Percolation.permeable?(material)
  end
end
