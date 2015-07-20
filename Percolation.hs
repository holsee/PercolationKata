data Cell = Blocked | Open | Water deriving (Eq, Show)

type Row = [Cell]
type MaterialComposition = [Row]

permeable :: MaterialComposition -> Bool
permeable rows =  Water `elem` bottomRow
    where bottomRow = foldl percolateDown inputWater rows
          inputWater = replicate rowLen Water
          rowLen = length $ head rows

percolateDown :: Row -> Row -> Row   
percolateDown upper lower = zipWith flow (fillSiblings upper) lower

fillSiblings :: Row -> Row
fillSiblings = fillRight . fillLeft

fillLeft :: Row -> Row
fillLeft = scanl1 flow

fillRight :: Row -> Row
fillRight =  reverse . fillLeft . reverse     

flow :: Cell -> Cell -> Cell
flow Water Open = Water
flow _ x = x
