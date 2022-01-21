//
//  actions.swift
//  impossible_sudoku
//
//  Created by Mike Mayer on 1/21/22.
//

import Foundation

// The design for actions assumes that they will always be undone
//  in a first-in/last-out order.  This means that the puzzle state
//  after undo will be exactly the same as it was before the action
//  was run.

protocol Action
{
  func run() -> Void
  func undo() -> Void
}

typealias Actions = Array<Action>
typealias CellDigit = (cell:Cell, digit:Int)

struct SetCellDigit : Action
{
  // Pretty simple, just sets/clears the digit and nothing else
  // It leaves availableDigits alone.
  let cell : Cell
  let digit : Int
  
  init?(cell:Cell, digit:Int)
  {
    guard cell.digit == nil else { return nil }
    guard cell.availableDigits.contains(digit) else { return nil }
    self.cell = cell
    self.digit = digit
  }
  
  func run() {
    cell.digit = digit
  }
  
  func undo() {
    cell.digit = nil
  }
}

class UpdateBasicElement : Action
{
  // This action adds the digit to the set of digits currently covered by
  // a row, col, box, or cage
  // It leaves availableCells alone.
  let element : BasicElement
  let digit : Int
  
  var removeDigit = Array<CellDigit>()
  
  init?(_ element:BasicElement, digit: Int)
  {
    if element.coveredDigits.contains(digit) { return nil }
    
    self.element = element
    self.digit = digit
    
    for index in element.availableCells[digit]
    {
      let cell = puzzle.cells[index]
      if cell.availableDigits.contains(digit) {
        removeDigit.append((cell,digit))
      }
    }
  }
  func run() {
    self.element.coveredDigits.insert(self.digit)
    removeDigit.forEach { (cell,digit) in cell.availableDigits.remove(digit) }
  }
  func undo() {
    self.element.coveredDigits.remove(self.digit)
    removeDigit.forEach { (cell,digit) in cell.availableDigits.insert(digit) }
  }
}

class UpdateRow : UpdateBasicElement
{
  // This action adds the digit to the set of digits currently covered by the row
  init?(cell:Cell, digit:Int)
  {
    super.init(cell.puzzle.rows[cell.row], digit: digit)
  }
}

class UpdateColumn : UpdateBasicElement
{
  // This action adds the digit to the set of digits currently covered by the column
  init?(cell:Cell, digit:Int)
  {
    super.init(cell.puzzle.cols[cell.col], digit: digit)
  }
}

class UpdateBox : UpdateBasicElement
{
  // This action adds the digit to the set of digits currently covered by the box
  init?(cell:Cell, digit:Int)
  {
    super.init(cell.puzzle.boxes[cell.box], digit: digit)
  }
}

class UpdateCage : UpdateBasicElement
{
  // This action adds the digit to the set of digits currently covered by the cage
  init?(cell:Cell, digit:Int)
  {
    if cell.cage == nil { return nil }
    super.init(cell.puzzle.cages[cell.cage!], digit: digit)
  }
}

struct UpdateNeighbors : Action
{
  // This action handles removing the sequential digits as candidates
  // from neighboring cells.  It keeps track of which candidates were
  // removed so that it can correctly add them back during undo
  
  var removeDigit = Array<CellDigit>()
  
  init?(cell:Cell, digit:Int)
  {
    let row = cell.row
    let col = cell.col
    
    var neighbors = Array<Cell>()
    let cells = cell.puzzle.cells
    
    if row > 0 { neighbors.append(cells[cellIndex(row: row-1, col: col)]) }
    if row < 8 { neighbors.append(cells[cellIndex(row: row+1, col: col)]) }
    if col > 0 { neighbors.append(cells[cellIndex(row: row, col: col-1)]) }
    if col < 8 { neighbors.append(cells[cellIndex(row: row, col: col+1)]) }
    
    neighbors.forEach { neighbor in
      if neighbor.availableDigits.contains(digit-1) { removeDigit.append((neighbor,digit-1)) }
      if neighbor.availableDigits.contains(digit+1) { removeDigit.append((neighbor,digit+1)) }
    }
    
    if removeDigit.count == 0 { return nil }
  }
  
  func run() {
    removeDigit.forEach { (cell,digit) in cell.availableDigits.remove(digit) }
  }
  
  func undo() {
    removeDigit.forEach { (cell,digit) in cell.availableDigits.insert(digit) }
  }
}
