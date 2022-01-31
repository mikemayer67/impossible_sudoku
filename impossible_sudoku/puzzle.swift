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
  

  func add(row:Int, col:Int, digit:Int)
  {
    add(cell:cells[cellIndex(row: row, col: col)],digit:digit)
  }
 
  @discardableResult
  func add(cell:Cell, digit:Int) -> UndoAction
  {
    solution.append((cell,digit))
    return cell.set(digit: digit)
  }
  
  @discardableResult
  func solve() -> Bool
  {
    let numFilledCells = self.solution.count
    if numFilledCells == 81 {
      show_state()
      return true
    }
    guard let (nominator,candidates) = self.bestCandidates() else { return false }
    
    let s = candidates.reduce("") { "\($0) \($1.cell.label)=\($1.digit+1)" }
    show_state()

    debug_flow("CANDIDATES \(nominator): \(s)")
    
    for candidate in candidates {
      debug_flow("ATTEMPTING: \(candidate.cell.label) = \(candidate.digit+1)")
      breakpoint(on:candidate.cell.label)
      
      let undo = self.add(cell: candidate.cell, digit: candidate.digit)
       
      if solve() { return true }

      debug_flow("FAILED: \(candidate.cell.label) = \(candidate.digit+1)")
      breakpoint(on:candidate.cell.label)
      
      undo()
      solution.removeLast()
    }
    return false
  }
  
  func bestCandidates() -> (String,Candidates)?
  {
    var bestCount = Int.max
    var nominator = ""
    var rval : Candidates?
    for element in elements {
      switch element.getCandidates() {
      case .Complete: break
      case .NoSolution: return nil
      case .hasCandidates(let candidates):
        if candidates.count < bestCount {
          bestCount = candidates.count
          nominator = element.label
          rval = candidates
        }
      }
    }
    
    guard rval != nil else { return nil }
    
    return (nominator,rval!)
  }
}
