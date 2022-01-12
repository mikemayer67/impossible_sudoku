//
//  dlx_row_node.swift
//  impossible_sudoku
//
//  Created by Mike Mayer on 12/31/21.
//

import Foundation

class DLXRow
{
  /// Represents placing a given digit in a given solution cell
  let label : String
  let digit : Int
  
  var firstNode : DLXCoverNode?
  
  var hidden = false
  var incompatible = Array<DLXRow>()
  var hiding = Array<DLXRow>()
  
  init(label:String, digit:Int)
  {
    self.label = label
    self.digit = digit
  }
  
  func add(_ node:DLXCoverNode) {
    if firstNode == nil {
      firstNode = node
    } else {
      node.insert(before: firstNode)
    }
  }
  
  func hide() -> Bool
  {
    guard !hidden else { return false }
    hidden = true
    
    for node in RowNodes(self) {
      node.unlink(.Row)
      node.column.nrows -= 1
    }
    return true
  }
  
  func unhide()
  {
    guard hidden else { return }
    hidden = false
    
    for node in RowNodes(self) {
      node.relink(.Row)
      node.column.nrows += 1
    }
  }
  
  func test_compatibility(with other:DLXRow) {}
  
  func hide_incompatible()
  {
    for r in self.incompatible {
      if r.hide() { self.hiding.append(r) }
    }
  }
  
  func unhide_hidden()
  {
    for r in self.hiding.reversed() {
      r.unhide()
    }
    self.hiding.removeAll()
  }
}

class DLXOnGridRow : DLXRow
{
  /// Represents placing a given digit in a given Sudoku grid cell
  let gridRow : Int
  let gridCol : Int
  
  init(gridRow:Int, gridCol:Int, digit:Int)
  {
    self.gridRow = gridRow
    self.gridCol = gridCol
    super.init(label:"\(gridRow)\(gridCol):\(digit)", digit:digit)
  }
  
  override func test_compatibility(with other:DLXRow)
  {
    guard let other = other as? DLXOnGridRow else { return }
    
    let delta_row = abs(self.gridRow - other.gridRow)
    let delta_col = abs(self.gridCol - other.gridCol)
    guard delta_row + delta_col == 1 else { return }
    
    let delta_digit = abs(self.digit - other.digit)
    if delta_digit == 1 {
      self.incompatible.append(other)
      other.incompatible.append(self)
    }
  }
}

class DLXOffGridRow : DLXRow
{
  /// Represents placing a given digit in an off-grid cell.
  /// Used to complete cages with less than 9 cells on the Sudoku grid
  let cage : Int
  let index : Int
  
  init(cage:Int, index:Int, digit:Int)
  {
    self.cage = cage
    self.index = index
    super.init(label:"\(cageLabels[cage])\(index):\(digit)", digit:digit)
  }

  override func test_compatibility(with other:DLXRow)
  {
    // only need to test other off-grid cells for same cage
    guard let other = other as? DLXOffGridRow,
          self.cage == other.cage,
          self.index != other.index
          else { return }
    
    if self.index < other.index,
       self.digit < other.digit { return }
    if self.index > other.index,
       self.digit > other.digit { return }
    
    self.incompatible.append(other)
    other.incompatible.append(self)
  }
}
