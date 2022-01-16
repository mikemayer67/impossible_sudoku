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
  var solution = Array<DLXRow>()
  var solved = false

  var cols : Cols { Cols(head) }
  var rows : Array<DLXRow> { head.rows }
  
  init()
  {
    head.add_rows()
    head.add_cols()
    
    for row in self.rows {
      for col in self.cols {
        if col.coveredBy(row: row) {
          col.nrows += 1
          let x = DLXCoverNode(row: row, column: col)
          row.add(x)
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
  
  func solve(_ solution_depth:Int=0) -> Bool
  {
    if self.head.solved {
      show_solution()
      self.solved = true
      return true
    }
    
    //pick column
    var c : DLXColumnNode!
    for cand in self.cols {
      if c == nil { c = cand }
      else if cand.nrows < c.nrows { c = cand }
    }
    guard c.nrows > 0 else {
      print("\(solution_depth): No solutions for \(c.label) [\(c.nrows)]")
      return false
    }
    
    debug("\(solution_depth): Solve \(c.label) [\(c.nrows)]")
    
    c.cover()
    for r in Rows(c) {
      print("  \(solution_depth): Solving for \(c.label):  Try row \(r.row.label)")
      solution.append(r.row)
      r.row.hide_incompatible()
      for node in RowNodes(r) {
        node.column.cover()
      }
      
      if debug_on { show_solution() }
      
      if solve(solution_depth + 1) { return true }
      
      for node in RowNodes(r,reverse: true) {
        node.column.uncover()
      }
      r.row.unhide_hidden()
            
      solution.removeLast()
      if debug_on { show_solution() }
    }
    c.uncover()
    
    return false
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
