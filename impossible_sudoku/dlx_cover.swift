//
//  dlx_cover.swift
//  impossible_sudoku
//
//  Created by Mike Mayer on 1/4/22.
//

import Foundation

class DLXCoverNode : DLXNode
{
  let row : DLXRow
  let column : DLXColumnNode
  
  init(row:DLXRow, column:DLXColumnNode)
  {
    self.row = row
    self.column = column
    super.init(label: row.label + "|" + column.label)
  }
}
