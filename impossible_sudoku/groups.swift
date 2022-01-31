//
//  groups.swift
//  impossible_sudoku
//
//  Created by Mike Mayer on 1/18/22.
//

import Foundation

typealias Cells = Set<Cell>
typealias CellDigit = (cell:Cell, digit:Int)
typealias Candidates = Array<CellDigit>
typealias UndoAction = ()->()

enum CandidatesResult
{
  case NoSolution
  case Complete
  case hasCandidates(Candidates)
}

class Element
{
  let label : String
  var complete : Bool { fatalError("abstract property") }
  
  func getCandidates() -> CandidatesResult
  {
    fatalError("abstract property")
  }
  
  init(_ label:String) {
    self.label = label
  }
}

class CellGroup : Element
{
  var _covered = Array<Bool>(repeating: false, count: 9)
  var _availableCells = Array<Cells>(repeating: Cells(), count: 9)
  
  override var complete : Bool { return _covered.allSatisfy({$0}) }
  
  func contains(_ digit:Int)->Bool { return _covered[digit] }
  func contains(_ cell:Cell, for digit:Int) -> Bool
  {
    return _availableCells[digit].contains(cell)
  }
  
  func link(_ cell:Cell)
  {
    for digit in 0..<9 {
      self._availableCells[digit].insert(cell)
    }
  }
  
  override func getCandidates() -> CandidatesResult
  {
    if complete { return .Complete }
    
    var bestCount = Int.max
    var bestDigit : Int?
    for digit in 0..<9 {
      if !_covered[digit] {
        let n = _availableCells[digit].count
        
        if n == 0 {
          debug_flow("No candidates for \(self.label)=\(digit+1)")
          return .NoSolution
        }
        if n < bestCount {
          bestCount = n
          bestDigit = digit
        }
      }
    }
    guard let digit = bestDigit else {
      fatalError("Should not get here if group is not complete")
    }
    
    let candidates = _availableCells[digit]
      .sorted { (a,b) -> Bool in a.label < b.label }
      .map { ($0,digit) }
    
    return .hasCandidates(candidates)
  }
  
  func set(_ cell:Cell, _ digit:Int) -> UndoAction?
  {
    if self._covered[digit] {
      fatalError("\(self.label) already contains \(digit)")
    }
    let debugString = "covering \(digit+1) with \(cell.label)"
    debug(self.label,debugString)
    _covered[digit] = true
    
    var undo = Array<UndoAction>()
    (0..<9).forEach {
      if let action = self.remove(cell, $0) { undo.append(action) }
    }
    
    _availableCells[digit].sorted(by: { (a, b) -> Bool in a.label < b.label }).forEach {
      if let action = $0.remove(digit: digit) { undo.append(action) }
    }
    
    return {
      undo.reversed().forEach { $0() }
      
      debug_undo(self.label,debugString)
      self._covered[digit] = false
    }
  }
  
  func remove(_ cell:Cell, _ digit:Int) -> UndoAction?
  {
    guard self._availableCells[digit].contains(cell) else { return nil }
    
    let debugString = "removing \(cell.label) for \(digit+1)"
    debug(self.label,debugString)
    self._availableCells[digit].remove(cell)
    
    return {
      debug_undo(self.label,debugString)
      self._availableCells[digit].insert(cell)
    }
  }
}

class Row : CellGroup
{
  let row : Int
  
  init(_ row:Int) {
    self.row = row
    super.init("R\(row)")
  }
}

class Column : CellGroup
{
  let column : Int
  
  init(_ column:Int) {
    self.column = column
    super.init("C\(column)")
  }
}

class Box : CellGroup
{
  let boxRow : Int
  let boxColumn : Int
  
  init(_ box:Int) {

    self.boxRow = box/3
    self.boxColumn = box%3
    super.init("B\(self.boxRow)\(self.boxColumn)")
  }
}

class Cage : CellGroup
{
  let cage : Int
  let requiredDigts : Int
  
  override var complete: Bool {
    return self._covered.filter({$0}).count == requiredDigts
  }
  
  init(_ cage:Int)
  {
    self.cage = cage
    guard let coords = cageCoords[cage] else { fatalError("invalid cage: \(cage)")}
    self.requiredDigts = coords.count
    super.init("\(cageLabels[cage])")
  }
}
