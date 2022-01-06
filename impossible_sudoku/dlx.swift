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
  
  func add_to_solution(_ row:DLXRowNode)
  {
    print("Add to Solution: \(row.label)")
    self.solution.append(row)
    
    for r in row.incompatible {
      if r.hide() {
        row.hiding.append(r)
      }
    }
    
    for node in RowNodes(row) {
      node.column.cover()
    }
  }
}
