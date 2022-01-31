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
  
  private var _digit : Int?
  private var _available = Array<Bool>(repeating: true, count: 9  )
  
  func hasAvailable(digit:Int) -> Bool { return _available[digit] }
  
  var digit : Int? { return _digit }
  
  override var complete: Bool { _digit != nil }
  
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
  
  override func getCandidates() ->  CandidatesResult
  {
    if _digit != nil {
      return .Complete
    }
    
    let candidates = (0..<9)
      .filter { _available[$0] }
      .map { (self,$0) }
    
    if candidates.isEmpty {
      debug_flow("No candidate digits s for \(self.label)")
      return .NoSolution
    }
    
    return .hasCandidates(candidates)
  }
  
  func set(digit:Int) -> UndoAction
  {
    guard self._digit == nil else {
      fatalError("Attempting to set \(self.label) to \(digit).  Already set to \(self._digit!)")
    }
    
    let debugString = "setting \(digit+1)"
    debug(self.label, debugString)
    self._digit = digit
    
    var undo = Array<UndoAction>()
    
    if let action = self.row.set(self,digit) {undo.append(action)}
    if let action = self.col.set(self,digit) {undo.append(action)}
    if let action = self.box.set(self,digit) {undo.append(action)}
    if let action = self.cage?.set(self,digit) {undo.append(action)}
    
    self.neighbors.forEach { neighbor in
      if let action = neighbor.remove(digit: digit-1) { undo.append(action) }
      if let action = neighbor.remove(digit: digit+1) { undo.append(action) }
    }
    
    return {
      undo.reversed().forEach {$0()}
      
      debug_undo(self.label, debugString)
      self._digit = nil
    }
  }
  
  func remove(digit:Int) -> UndoAction?
  {
    guard self._available[digit] else { return nil }
    
    let debugString = "removing \(digit+1)"
    debug(self.label,debugString)
    self._available[digit] = false
    
    var undo = Array<UndoAction>()
    
    if let action = self.row.remove(self,digit) { undo.append(action) }
    if let action = self.col.remove(self,digit) { undo.append(action) }
    if let action = self.box.remove(self,digit) { undo.append(action) }
    if let action = self.cage?.remove(self,digit) { undo.append(action) }
    
    return {
      undo.reversed().forEach { $0() }
      debug_undo(self.label,debugString)
      self._available[digit] = true
    }
  }
}
