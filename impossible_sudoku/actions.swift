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

protocol Undoable
{
  func undo() -> Void
}

typealias Undoables = Array<Undoable>

struct SetCellDigit : Undoable
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
  
  var addDigitToRow : Undoable?
  var addDigitToCol : Undoable?
  var addDigitToBox : Undoable?
  var addDigitToCage : Undoable?
  var updateNeighbors : Undoable?
    
  init?(puzzle:Puzzle, cell:Cell, digit:Int)
  {
    guard cell.availableDigits.contains(digit) else { return nil }
    self.cell = cell
    self.digit = digit
        
    cell.digit = digit
    debug(1,cell.label,"set digit \(digit+1)")
    
    breakpoint(on: cell.label)
    
    addDigitToRow = AddDigitToGroup(cell.row, cell:cell, digit:digit)
    addDigitToCol = AddDigitToGroup(cell.col, cell:cell, digit:digit)
    addDigitToBox = AddDigitToGroup(cell.box, cell:cell, digit:digit)
    addDigitToCage = AddDigitToGroup(cell.cage, cell:cell, digit:digit)
    
    updateNeighbors = UpdateNeighbors(cell:cell, digit: digit)
  }
  
  func undo() {
    updateNeighbors?.undo()
    
    addDigitToCage?.undo()
    addDigitToBox?.undo()
    addDigitToCol?.undo()
    addDigitToRow?.undo()
    
    debug(1,self.cell.label, "unset digit \(digit+1)")
    cell.digit = nil
  }
}

class AddDigitToGroup : Undoable
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
  var subActions = Array<Undoable>()
      
  init?(_ group:CellGroup?, cell:Cell, digit:Int)
  {
    guard let group = group else { return nil }
    if group.coveredDigits.contains(digit) {
      fatalError("Cannot cover \(group.label)=\(digit): alreay covered")
    }
    self.group = group
    self.cell = cell
    self.digit = digit
    
    debug(2,group.label, "covering \(digit+1)")
    group.coveredDigits.insert(digit)
    
    self.digitsWithCell = Array(0..<9)
      .filter { group.availableCells[$0].contains(cell) }
    
    digitsWithCell.forEach { digit in
      debug(3,"\(group.label)=\(digit+1)","remove \(cell.label)")
      group.availableCells[digit].remove(cell)
    }
    
    group.cellsAvailable(for:digit).forEach { cell in
      subActions.append( RemoveCellAvailability(cell:cell, digit:digit) )
    }
  }
  
  func undo() {
    subActions.reversed().forEach { $0.undo() }
    
    digitsWithCell.reversed().forEach { digit in
        debug(3,"\(group.label)=\(digit+1)","insert \(cell.label)")
        group.availableCells[digit].insert(cell)
    }
    
    debug(2,group.label,"uncovering \(digit+1)")
    group.coveredDigits.remove(digit)
  }
}

struct RemoveCellAvailability : Undoable
{
  // Removes digit from cell's candidate digis
  // Removes cell as candidate for digit in each of its containing groups
  let cell: Cell
  let digit: Int

  let removeFromRow : Undoable?
  let removeFromCol : Undoable?
  let removeFromBox : Undoable?
  let removeFromCage: Undoable?
  
  init(cell:Cell, digit:Int)
  {
    guard cell.availableDigits.contains(digit) else
    {
      fatalError("Cannot remove \(digit+1) from \(cell.label)): already removed")
    }
    self.cell = cell
    self.digit = digit
    debug(3,cell.label,"remove \(digit+1)")
    cell.availableDigits.remove(digit)
    
    removeFromRow = RemoveCellFromGroup(cell.row,cell:cell,digit:digit)
    removeFromCol = RemoveCellFromGroup(cell.col,cell:cell,digit:digit)
    removeFromBox = RemoveCellFromGroup(cell.box,cell:cell,digit:digit)
    removeFromCage = RemoveCellFromGroup(cell.cage,cell:cell,digit:digit)
  }
  func undo()
  {
    removeFromCage?.undo()
    removeFromBox?.undo()
    removeFromCol?.undo()
    removeFromRow?.undo()
    
    debug(3,cell.label,"insert \(digit+1)")
    cell.availableDigits.insert(digit)
  }
}

struct RemoveCellFromGroup : Undoable
{
  // Removes cell as candidate from the specified group
  let group : CellGroup
  let cell : Cell
  let digit : Int
  init?(_ group:CellGroup?,cell:Cell,digit:Int)
  {
    guard let group = group else { return nil }
    guard group.availableCells[digit].contains(cell) else {
      fatalError("Cannot remove \(cell) from \(group.label) for \(digit): already removed")
    }
    self.group = group
    self.cell = cell
    self.digit = digit
    debug(4,"\(group.label)=\(digit+1)","remove \(cell.label)")
    group.availableCells[digit].remove(cell)
  }
  func undo()
  {
    debug(4,"\(group.label)=\(digit+1)","insert \(cell.label)")
    group.availableCells[digit].insert(cell)
  }
}

struct UpdateNeighbors : Undoable
{
  // This action handles removing the sequential digits as candidates
  // from neighboring cells.  It keeps track of which candidates were
  // removed so that it can correctly add them back during undo
  
  var removeDigit = Array<CellDigit>()
  
  init?(cell:Cell, digit:Int)
  {
    cell.neighbors.forEach { neighbor in
      if neighbor.digit == nil {
        if neighbor.availableDigits.contains(digit-1) { removeDigit.append((neighbor,digit-1)) }
        if neighbor.availableDigits.contains(digit+1) { removeDigit.append((neighbor,digit+1)) }
      }
    }
    if removeDigit.count == 0 { return nil }
    
    removeDigit.forEach { (cell,digit) in
      debug(2,cell.label,"remove \(digit+1)")
      cell.availableDigits.remove(digit)
      debug(3,"\(cell.row.label)=\(digit+1)","remove \(cell.label)")
      cell.row.availableCells[digit].remove(cell)
      debug(3,"\(cell.col.label)=\(digit+1)","remove \(cell.label)")
      cell.col.availableCells[digit].remove(cell)
      debug(3,"\(cell.box.label)=\(digit+1)","remove \(cell.label)")
      cell.box.availableCells[digit].remove(cell)
      if cell.cage != nil { debug(3,"\(cell.cage!.label)=\(digit+1)","remove \(cell.label)") }
      cell.cage?.availableCells[digit].remove(cell)
    }
  }
  
  func undo() {
    removeDigit.reversed().forEach { (cell,digit) in
      if cell.cage != nil { debug(3,"\(cell.cage!.label)=\(digit+1)","insert \(cell.label)") }
      cell.cage?.availableCells[digit].insert(cell)
      debug(3,"\(cell.box.label)=\(digit+1)","remove \(cell.label)")
      cell.box.availableCells[digit].insert(cell)
      debug(3,"\(cell.col.label)=\(digit+1)","remove \(cell.label)")
      cell.col.availableCells[digit].insert(cell)
      debug(3,"\(cell.row.label)=\(digit+1)","remove \(cell.label)")
      cell.row.availableCells[digit].insert(cell)
      debug(2,cell.label,"insert \(digit+1)")
      cell.availableDigits.insert(digit)
    }
  }
}
