//
//  puzzle.swift
//  impossible_sudoku
//
//  Created by Mike Mayer on 1/19/22.
//

import Foundation

typealias Move = (cell:Cell, digit:Int)

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
      rows.append(Row(digit))
      cols.append(Column(digit))
      boxes.append(Box(digit))
      cages.append(Cage(digit))
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
  func add(row:Int, col:Int, digit:Int) -> SetCellDigit?
  {
    return add(cell:cells[cellIndex(row: row, col: col)],digit:digit)
  }
  
  func add(cell:Cell, digit:Int) -> SetCellDigit?
  {
    guard let setCellDigit = SetCellDigit(puzzle:self, cell:cell, digit: digit) else { return nil }
    solution.append(Move(cell,digit))
    setCellDigit.run()
    return setCellDigit
  }
}
