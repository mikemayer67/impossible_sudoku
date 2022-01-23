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

struct SetCellDigit : Action
{
  // There are a number of things that must happen when assigning
  // a digit to a cell
  //
  // Within the cell itself:
  // - the digit property must be set
  // - (the available digits can be left alone as non-nil digit signals this cell is complete)
  //
  // For each of the cell's groups (row, col, box, cage):
  // - mark the digit as covered
  // - remove the cell from all digits' available cell lists
  //
  // Within all other cells in each group (row, col, box, cage):
  // - Remove the digit from the list of available digits
  // - Remove the cell from each of its groups (row, col, box, cage)
  let cell : Cell
  let digit : Int
  
  private(set) var subActions = Actions()
  
  init?(puzzle:Puzzle, cell:Cell, digit:Int)
  {
    guard cell.digit == nil else { return nil }
    guard cell.availableDigits.contains(digit) else { return nil }
    self.cell = cell
    self.digit = digit
    
    subActions.append(UpdateCellGroup(cell.row, cell:cell, digit:digit))
    subActions.append(UpdateCellGroup(cell.col, cell:cell, digit:digit))
    subActions.append(UpdateCellGroup(cell.box, cell:cell, digit:digit))
    
    if let cage = cell.cage {
      subActions.append(UpdateCellGroup(cage, cell:cell, digit:digit))
    }
    if let updateNeighbors = UpdateNeighbors(cell:cell, digit: digit)
    {
      subActions.append(updateNeighbors)
    }
  }
  
  func run() {
    cell.digit = digit
    subActions.forEach { $0.run() }
  }
  
  func undo() {
    subActions.reversed().forEach { $0.undo() }
    cell.digit = nil
  }
}

class UpdateCellGroup : Action
{
  // For each of the cell's groups (row, col, box, cage):
  // - mark the digit as covered
  // - remove the cell from all digits' available cell lists
  //
  // Within all other cells in each group (row, col, box, cage):
  // - Remove the digit from the list of available digits
  // - Remove the cell from each of its groups (row, col, box, cage)
  
  let group : CellGroup
  let cell : Cell
  let digit : Int
  
  let digitsWithCell : Array<Int>
  let cellsWithDigit : Array<Cell>
    
  init(_ group:CellGroup, cell:Cell, digit:Int)
  {
    if group.coveredDigits.contains(digit) { fatalError("should never get here") }
    
    self.group = group
    self.cell = cell
    self.digit = digit
    
    self.digitsWithCell = Array(0..<9)
      .filter { $0 != digit }
      .filter { group.availableCells[$0].contains(cell) }
    
    self.cellsWithDigit = group.availableCells[digit]
      .filter { $0 != cell }
  }
  func run() {
    group.coveredDigits.insert(digit)
    
    digitsWithCell.forEach { group.availableCells[$0].remove(cell) }
    
    cellsWithDigit.forEach { cell in
      cell.availableDigits.remove(digit)
      cell.row.availableCells[self.digit].remove(cell)
      cell.col.availableCells[self.digit].remove(cell)
      cell.box.availableCells[self.digit].remove(cell)
      cell.cage?.availableCells[self.digit].remove(cell)
    }
  }
  func undo() {
    cellsWithDigit.reversed().forEach { cell in
      cell.cage?.availableCells[self.digit].insert(cell)
      cell.box.availableCells[self.digit].insert(cell)
      cell.col.availableCells[self.digit].insert(cell)
      cell.row.availableCells[self.digit].insert(cell)
      cell.availableDigits.insert(digit)
    }
    
    digitsWithCell.reversed().forEach { group.availableCells[$0].insert(cell) }
    
    group.coveredDigits.remove(digit)
  }
}

struct UpdateNeighbors : Action
{
  // This action handles removing the sequential digits as candidates
  // from neighboring cells.  It keeps track of which candidates were
  // removed so that it can correctly add them back during undo
  
  var removeDigit = Array<(cell:Cell,digit:Int)>()
  
  init?(cell:Cell, digit:Int)
  {
    cell.neighbors.forEach { neighbor in
      if neighbor.availableDigits.contains(digit-1) { removeDigit.append((neighbor,digit-1)) }
      if neighbor.availableDigits.contains(digit+1) { removeDigit.append((neighbor,digit+1)) }
    }
    
    if removeDigit.count == 0 { return nil }
  }
  
  func run() {
    removeDigit.forEach { (cell,digit) in
      cell.availableDigits.remove(digit)
      cell.row.availableCells[digit].remove(cell)
      cell.col.availableCells[digit].remove(cell)
      cell.box.availableCells[digit].remove(cell)
      cell.cage?.availableCells[digit].remove(cell)
    }
  }
  
  func undo() {
    removeDigit.forEach { (cell,digit) in
      cell.cage?.availableCells[digit].insert(cell)
      cell.box.availableCells[digit].insert(cell)
      cell.col.availableCells[digit].insert(cell)
      cell.row.availableCells[digit].insert(cell)
      cell.availableDigits.insert(digit)
    }
  }
}
