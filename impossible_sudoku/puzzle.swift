//
//  puzzle.swift
//  impossible_sudoku
//
//  Created by Mike Mayer on 1/19/22.
//

import Foundation

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
  private(set) var solution = Array<CellDigit>()
  
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
    solution.append((cell,digit))
    return setCellDigit
  }
  
  @discardableResult
  func solve() -> Bool
  {
    let numFilledCells = self.solution.count
    if numFilledCells == 81 {
      show_state()
      return true
    }
    guard let candidates = self.bestCandidates else { return false }
    
    let s = candidates.reduce("") { "\($0) \($1.cell.label)=\($1.digit+1)" }
    show_state()

//    print("CANDIDATES: \(s)")
    
    for candidate in candidates {
//      print("ATTEMPTING: \(candidate.cell.label) = \(candidate.digit+1)")
      breakpoint(on:candidate.cell.label)
      guard let attempt = self.add(cell: candidate.cell, digit: candidate.digit)
      else {
        fatalError("Coding error: failed to add \(candidate.digit+1) to \(candidate.cell.label)")
      }
       
      if solve() { return true }

 //     print("FAILED: \(candidate.cell.label) = \(candidate.digit+1)")
      breakpoint(on:candidate.cell.label)
      attempt.undo()
      solution.removeLast()
    }
    return false
  }
  
  var bestCandidates : Candidates?
  {
    var bestCount = Int.max
    var rval : Candidates?
    for element in elements {
      if element.complete { continue }
      
      guard let candidates = element.candidates else { return nil }
      
      if candidates.count < bestCount
      {
          bestCount = candidates.count
          rval = candidates
      }
    }
    return rval
  }
}
