//
//  puzzle.swift
//  impossible_sudoku
//
//  Created by Mike Mayer on 1/19/22.
//

import Foundation

typealias Move = (row:Int, col:Int, digit:Int)

func cellIndex(row:Int,col:Int) -> Int { 9*row + col }
func boxIndex(row:Int,col:Int) -> Int { 3*(row/3) + (col/3) }
func boxIndex(cell:Int) -> Int { boxIndex(row: cell/9, col: cell%9) }

class Puzzle
{
  private(set) var rows = Array<Row>()
  private(set) var cols = Array<Column>()
  private(set) var boxes = Array<Box>()
  private(set) var cages = Array<Cage>()
  private(set) var cells = Array<Cell>()
  
  private(set) var elements = Array<Element>()
  private(set) var solution = Array<Move>()
  
  init()
  {
    for digit in 0..<9 {
      rows.append(Row(self,digit))
      cols.append(Column(self,digit))
      boxes.append(Box(self,digit))
      cages.append(Cage(self,digit))
    }
    for cell in 0..<81 {
      cells.append(Cell(self,cell))
    }
    
    elements.append(contentsOf: rows)
    elements.append(contentsOf: cols)
    elements.append(contentsOf: boxes)
    elements.append(contentsOf: cages)
    elements.append(contentsOf: cells)
  }
  
  @discardableResult
  func add(row:Int, col:Int, digit:Int) -> Actions?
  {
    return add(cell:cellIndex(row: row, col: col),digit:digit)
  }
  
  func add(cell cell_index:Int, digit:Int) -> Actions?
  {
    var actions = Array<Action>()
    
    let cell = self.cells[cell_index]
    
    guard let setDigit = SetCellDigit(cell:cell, digit: digit) else { return nil }
    actions.append(setDigit)
    
    if let addressNeighbors = UpdateNeighbors(cell:cell, digit:digit) {
      actions.append(addressNeighbors)
    }
    
    guard
      let updateRow = UpdateRow(cell:cell, digit:digit),
      let updateCol = UpdateColumn(cell:cell, digit:digit),
      let updateBox = UpdateBox(cell:cell, digit:digit)
    else {
      fatalError("coding logic error")
    }
    
    actions.append(updateRow)
    actions.append(updateCol)
    actions.append(updateBox)
    
    if let updateCage = UpdateCage(cell:cell, digit:digit) {
      actions.append(updateCage)
    }
    
    actions.forEach { (action) in action.run() }
    
    return actions
  }
}
