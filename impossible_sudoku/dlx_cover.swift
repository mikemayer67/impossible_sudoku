//
//  dlx_cover.swift
//  impossible_sudoku
//
//  Created by Mike Mayer on 1/4/22.
//

import Foundation

class DLXCoverNode : DLXNode
{
  let row : DLXRowNode
  let column : DLXColumnNode
  
  init(row:DLXRowNode, column:DLXColumnNode)
  {
    self.row = row
    self.column = column
    super.init(label: row.label + "|" + column.label)
  }
}
