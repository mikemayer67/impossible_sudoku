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
  
  func add_given(row:Int, col:Int, digit:Int)
  {
    for r in self.rows {
      if r.digit == digit,
         let r = r as? DLXOnGridRow,
         r.gridRow == row,
         r.gridCol == col
      {
        self.solution.append(r)
        r.incompatible.forEach { ir in
          if ir.hide() {
            r.hiding.append(ir)
          }
        }
        RowNodes(r).forEach {
          node in node.column.cover()
        }
      }
    }
  }
  
}
