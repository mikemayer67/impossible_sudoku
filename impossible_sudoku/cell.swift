//
//  cell.swift
//  impossible_sudoku
//
//  Created by Mike Mayer on 1/18/22.
//

import Foundation

class Cell : Element, Hashable
{
  let cell : Int
  
  let row : Row
  let col : Column
  let box : Box
  let cage : Cage?
  private(set) var neighbors = Array<Cell>()
  
  var digit : Int?
  var availableDigits : Digits
  
  override var complete: Bool { digit != nil }
  
  init(_ puzzle:Puzzle, _ cell:Int)
  {
    self.cell = cell
    
    let row = self.cell / 9
    let col = self.cell % 9
    let box = 3*(row/3) + (col/3)
    
    self.row = puzzle.rows[row]
    self.col = puzzle.cols[col]
    self.box = puzzle.boxes[box]
    
    if let cage = cageDef[row][col] {
      self.cage = puzzle.cages[cage]
    } else {
      self.cage = nil
    }
    
    self.availableDigits = Digits(0..<9)
    
    super.init("[\(cell/9)\(cell%9)]")
    
    if row > 0 {
      self.neighbors.append(puzzle.cells[cell-9])
      puzzle.cells[cell-9].neighbors.append(self)
    }
    
    if col > 0 {
      self.neighbors.append(puzzle.cells[cell-1])
      puzzle.cells[cell-1].neighbors.append(self)
    }
    
    self.row.link(self)
    self.col.link(self)
    self.box.link(self)
    self.cage?.link(self)
  }
  
  static func == (lhs: Cell, rhs: Cell) -> Bool { lhs.cell == rhs.cell }
  
  func hash(into hasher: inout Hasher) { hasher.combine(self.cell) }
}
