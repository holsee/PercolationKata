import Percolation._

sealed trait Cell
case object Blocked extends Cell
case object Open extends Cell
case object Water extends Cell

case class MaterialComposition(rows: List[Row]) {
  def isPermeable = {
    def percolateDown(upper: Row, lower: Row): Row = {
      val filled = upper.fillSiblings
      Row(filled.cells.zip(lower.cells).map(flow.tupled))
    }

    val rowLen = rows.head.cells.length
    val inputWater = Row(List.fill(rowLen)(Water))
    val bottomRow = rows.foldLeft(inputWater)(percolateDown)
    bottomRow.cells.contains(Water)
  }
}

case class Row(cells: List[Cell]) {
  def fillSiblings = {
    val filledFromLeft = cells.scanLeft(Open: Cell)(flow).tail
    val filledFromRight = filledFromLeft.reverse.scanLeft(Open: Cell)(flow).tail.reverse
    Row(filledFromRight)
  }
}

object Percolation {
  val flow: (Cell, Cell) => Cell = {
    case (Water, Open) => Water
    case (_, x) => x
  }
}


 