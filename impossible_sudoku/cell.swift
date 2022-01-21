//
//  cell.swift
//  impossible_sudoku
//
//  Created by Mike Mayer on 1/18/22.
//

import Foundation

class Cell : Element
{
  let row : Int
  let col : Int
  let box : Int
  let cage : Int?
  var digit : Int?
  
  var availableDigits : Digits
  
  override var complete: Bool { digit != nil }
  
  init(_ puzzle:Puzzle, _ cell:Int) {
    let row = cell / 9
    let col = cell % 9
    self.row = row
    self.col = col
    self.box = 3*(row/3) + (col/3)
    self.cage = cageDef[row][col]
    availableDigits = Digits(0..<9)
    super.init(puzzle, "[\(row)\(col)]")
  }
}
