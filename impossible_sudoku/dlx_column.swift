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
        fatalError("Reduced number of rows covering \(self.label) to \(self.nrows)")
      }
      if watching.contains(self.label) {
        debug("ADJUSTING \(self.label) from \(oldValue) to \(self.nrows)")
      }
    }
  }
  func coveredBy(row:DLXRow) -> Bool {
    fatalError("Coding error... this is an abstract method")
  }
  
  func cover()
  {
    let covering = Rows(self).reduce("") { (r, n) -> String in "\(r) \(n.row.label)" }
    debug("  cover col \(self.label) [\(self.nrows)] : \(covering)")
    self.unlink(.Col)
    for r in Rows(self) {
      r.row.hidden = true
      
      let covering = RowNodes(r).reduce("") { (r, n) -> String in "\(r) \(n.column.label)" }
      debug("   cover row \(r.row.label) [\(r.label)] : \(covering)")
      for node in RowNodes(r) {
        if watching.contains(node.column.label) {
          debug("    unlink \(node.label)")
        }
        node.unlink(.Row)
        node.column.nrows -= 1
      }
    }
  }
  
  func uncover()
  {
    let uncovering = Rows(self).reduce("") { (r, n) -> String in "\(r) \(n.row.label)" }
    debug("  uncover col \(self.label) : \(uncovering)")
    for r in Rows(self,reverse: true) {
      let uncovering = RowNodes(r).reduce("") { (r, n) -> String in "\(r) \(n.column.label)" }
      debug ("   uncover row \(r.row.label) [\(r.label)] : \(uncovering)")
      for node in RowNodes(r, reverse: true) {
        if watching.contains(node.column.label) {
          debug("    relink \(node.label)")
        }
        node.relink(.Row)
        node.column.nrows += 1
      }
      r.row.hidden = false
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
  override func coveredBy(row:DLXRow) -> Bool {
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
  override func coveredBy(row:DLXRow) -> Bool {
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
  override func coveredBy(row:DLXRow) -> Bool {
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
  override func coveredBy(row:DLXRow) -> Bool {
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
  override func coveredBy(row:DLXRow) -> Bool {
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
  override func coveredBy(row:DLXRow) -> Bool {
    guard let row = row as? DLXOffGridRow else { return false }
    if row.cage != self.cage { return false }
    if row.index != self.index { return false }
    return true
  }
}



