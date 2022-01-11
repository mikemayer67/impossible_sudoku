//
//  dlx_column.swift
//  impossible_sudoku
//
//  Created by Mike Mayer on 1/4/22.
//

import Foundation

class DLXColumnNode : DLXNode
{
  var nrows = 0
  {
    didSet {
      if self.nrows < 0 {
        print("Reduced number of rows covering \(self.label) to \(self.nrows)")
      }
      if let x = self as? DLXBoxColumn,
         x.boxRow == 1,
         x.boxCol == 2,
         x.digit == 2 {
        print("Reduced \(x.label) to \(x.nrows)")
      }
    }
  }
  func coveredBy(row:DLXRowNode) -> Bool {
    fatalError("Coding error... this is an abstract method")
  }
  
  func cover()
  {
//    print("  cover col \(self.label) [\(self.nrows)]")
    self.unlink(.Col)
    for r in ColNodes(self) {
//      print("   cover row \(r.row.label) [\(r.label)]")
      for node in RowNodes(r.row) {
        if node !== r {
//          print("    unlink node\(node.label)")
          node.unlink(.Row)
          node.column.nrows -= 1
        }
      }
    }
  }
  
  func uncover()
  {
//    print("  uncover col \(self.label)")
    for r in ColNodes(self,reverse: true) {
//      print ("  uncover row \(r.row.label) [\(r.label)]")
      for node in RowNodes(r.row, reverse: true) {
        if node !== r {
//          print("  relink node\(node.label)")
          node.relink(.Row)
          node.column.nrows += 1
        }
      }
    }
    self.relink(.Col)
  }
}

class DLXRowColumn : DLXColumnNode
{
  /// DLX columns which ensures every digit appears in each row in the sudoku grid
  var gridRow : Int
  var digit : Int
  init(gridRow:Int, digit:Int) {
    self.gridRow = gridRow
    self.digit = digit
    super.init(label:"R\(gridRow)=\(digit)")
  }
  override func coveredBy(row:DLXRowNode) -> Bool {
    if row.digit != self.digit { return false }
    guard let row = row as? DLXOnGridRow else { return false }
    return  row.gridRow == self.gridRow
  }
}

class DLXColumnColumn : DLXColumnNode
{
  /// DLX columns which ensures every digit appears in each column in the sudoku grid
  var gridCol : Int
  var digit : Int
  init(gridCol:Int, digit:Int) {
    self.gridCol = gridCol
    self.digit = digit
    super.init(label:"C\(gridCol)=\(digit)")
  }
  override func coveredBy(row:DLXRowNode) -> Bool {
    if row.digit != self.digit { return false }
    guard let row = row as? DLXOnGridRow else { return false }
    return row.gridCol == self.gridCol
  }
}

class DLXBoxColumn : DLXColumnNode
{
  /// DLX columns which ensures every digit appears in each box in the sudoku grid
  var boxCol : Int
  var boxRow : Int
  var digit : Int
  init(boxRow:Int, boxCol:Int, digit:Int) {
    self.boxCol = boxCol
    self.boxRow = boxRow
    self.digit = digit
    super.init(label:"B\(boxRow)\(boxCol)=\(digit)")
  }
  override func coveredBy(row:DLXRowNode) -> Bool {
    if row.digit != self.digit { return false }
    guard let row = row as? DLXOnGridRow else { return false }
    if row.gridCol / 3 != self.boxCol { return false }
    if row.gridRow / 3 != self.boxRow { return false }
    return true
  }
}

class DLXCageColumn : DLXColumnNode
{
  /// DLX columns which ensures every digit appears in each cage in the impossible sudoku grid
  var cage : Int
  var digit : Int
  init(cage:Int, digit:Int) {
    self.cage = cage
    self.digit = digit
    super.init(label:"\(cageLabels[cage])=\(digit)")
  }
  override func coveredBy(row:DLXRowNode) -> Bool {
    if row.digit != self.digit { return false }
    if let row = row as? DLXOnGridRow {
      return cageDef[row.gridRow][row.gridCol] == cage
    }
    if let row = row as? DLXOffGridRow {
      return cage == row.cage
    }
    fatalError("Coding Error, should never get here")
  }
}

class DLXGridCellColumn : DLXColumnNode
{
  /// DLX columns which ensures each cell in the sudoku grid contains only one digit
  var gridRow : Int
  var gridCol : Int
  init(gridRow:Int, gridCol:Int) {
    self.gridRow = gridRow
    self.gridCol = gridCol
    super.init(label:"[\(gridRow)\(gridCol)]")
  }
  override func coveredBy(row:DLXRowNode) -> Bool {
    guard let row = row as? DLXOnGridRow else { return false }
    if row.gridRow != self.gridRow { return false }
    if row.gridCol != self.gridCol { return false }
    return true
  }
}

class DLXCageCellColumn : DLXColumnNode
{
  /// DLX columns which ensures each off grid cage cell contains only one digit
  var cage : Int
  var index : Int
  init(cage:Int, index:Int) {
    self.cage = cage
    self.index = index
    super.init(label:"[\(cageLabels[cage])\(index)]")
  }
  override func coveredBy(row:DLXRowNode) -> Bool {
    guard let row = row as? DLXOffGridRow else { return false }
    if row.cage != self.cage { return false }
    if row.index != self.index { return false }
    return true
  }
}



