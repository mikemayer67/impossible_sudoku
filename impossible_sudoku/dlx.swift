//
//  dlx.swift
//  impossible_sudoku
//
//  Created by Mike Mayer on 1/6/22.
//

import Foundation

enum GridDimension
{
  case Row
  case Col
}

class DLX
{
  let head = DLXHeadNode()
  var solution = Array<DLXRowNode>()
  var solved = false

  let rows : Rows
  let cols : Cols
  
  init()
  {
    head.add_rows()
    head.add_cols()
    
    self.rows = Rows(head)
    self.cols = Cols(head)
    
    for row in self.rows {
      for col in self.cols {
        if row.covers(column:col) {
          col.nrows += 1
          let x = DLXCoverNode(row: row, column: col)
          x.insert(before: row)
          x.insert(above: col)
        }
      }
    }
  }
  
  func add_given(row:Int, col:Int, digit:Int)
  {
    for r in self.rows {
      if r.digit == digit,
         let r = r as? DLXOnGridRow,
         r.gridRow == row,
         r.gridCol == col
      {
        self.solution.append(r)
        r.hide_incompatible()
        for node in RowNodes(r) {
          node.column.cover()
        }
      }
    }
  }
  
  func solve(_ solution_depth:Int=0)
  {
    if self.head.solved {
      show_solution()
      self.solved = true
      return
    }
    
    //pick column
    var c : DLXColumnNode!
    for cand in self.cols {
      if c == nil { c = cand }
      else if cand.nrows < c.nrows { c = cand }
    }
    guard c.nrows > 0 else {
      print("No solutions for \(c.label)")
      return
    }
    
    print("Solve(\(solution_depth)) c:\(c.label) [\(c.nrows)]")
    
    c.cover()
    for r in ColNodes(c) {
      print("Try row \(r.row.label)")
      solution.append(r.row)
      r.row.hide_incompatible()
      show_solution()
      
      for node in RowNodes(r.row) {
        if node !== r {
          node.column.cover()
        }
      }
      
      solve(solution_depth + 1)
      
      for node in RowNodes(r.row,reverse: true) {
        if node !== r {
          node.column.uncover()
        }
      }
      r.row.unhide_hidden()
            
      solution.removeLast()
    }
  }
  
  func show_solution()
  {
    var grid = Array<Array<Int>>(repeating: Array<Int>(repeating: 0, count: 9), count: 9)
    for r in self.solution {
      if let r = r as? DLXOnGridRow {
        grid[r.gridRow][r.gridCol] = r.digit
      }
    }
    print("Grid:")
    for (r,row) in grid.enumerated() {
      let digits = row.reduce("") { (r, d) -> String in r + " \(d)" }
      let cages = (0..<9).reduce("") { (s, c) -> String in
        if let cage = cageDef[r][c] { return "\(s) \(cageLabels[cage])" }
        return "\(s)  "
      }
      print("  \(digits)  \(cages)")
    }
    
    var extra = "\nExtra:"
    for r in self.solution {
      if let r = r as? DLXOffGridRow {
        extra = extra + " \(r.label)"
      }
    }
    print(extra)
    print()
  }
}
