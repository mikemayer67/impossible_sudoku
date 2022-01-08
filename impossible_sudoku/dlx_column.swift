//
//  dlx_column.swift
//  impossible_sudoku
//
//  Created by Mike Mayer on 1/4/22.
//

import Foundation

enum DLXColumnType {
  case GridRow
  case GridCol
  case GridBox
  case Cage
  case GridCell
  case CageCell
}

class DLXColumnNode : DLXNode
{
  var nrows = 0
  let type : DLXColumnType
  let index : Int
  let digit : Int
  
  init(gridRow:Int, digit:Int) {
    self.type = DLXColumnType.GridRow
    self.index = gridRow
    self.digit = digit
    super.init(label: "R\(index)=\(digit)")
  }
  
  init(gridCol:Int, digit:Int) {
    self.type = DLXColumnType.GridCol
    self.index = gridCol
    self.digit = digit
    super.init(label: "C\(index)=\(digit)")
  }
  
  init(gridBox:Int, digit:Int) {
    self.type = DLXColumnType.GridBox
    self.index = gridBox
    self.digit = digit
    super.init(label: "B\(index)=\(digit)")
  }
  
  init(gridRow:Int, gridCol:Int) {
    self.type = DLXColumnType.GridCell
    self.index = 9*gridRow + gridCol
    super.init(label: "B\(index)=\(digit)")
  }
  
  init(cage:Int, digit:Int)
  {
    self.type = DLXColumnType.Cage
    self.index = cage
    self.digit = digit
    let key = cageLabels[cage]
    super.init(label: "X\(key)=\(digit)")
  }
  
  func cover()
  {
    self.unlink(.Col)
    for r in ColNodes(self) {
      for node in RowNodes(r.row) {
        if node !== r {
          node.unlink(.Row)
          node.column.nrows -= 1
        }
      }
    }
  }
  
  func uncover()
  {
    for r in ColNodes(self,reverse: true) {
      for node in RowNodes(r.row, reverse: true) {
        if node !== r {
          node.relink(.Row)
          node.column.nrows += 1
        }
      }
    }
    self.relink(.Col)
  }
}
