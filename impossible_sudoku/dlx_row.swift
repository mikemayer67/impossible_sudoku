//
//  dlx_row_node.swift
//  impossible_sudoku
//
//  Created by Mike Mayer on 12/31/21.
//

import Foundation

class DLXRowNode : DLXNode
{
  /// Represents placing a given digit in a given solution cell
  let digit : Int
  
  var selected = false
  var incompatible = Array<DLXRowNode>()
  var blocking = Array<DLXRowNode>()
  
  init(label:String, digit:Int)
  {
    self.digit = digit
    super.init(label:label)
  }
}

class DLXOnGridRow : DLXRowNode
{
  /// Represents placing a given digit in a given Sudoku grid cell
  let gridRow : Int
  let gridCol : Int
  
  init(gridRow:Int, gridCol:Int, digit:Int)
  {
    self.gridRow = gridRow
    self.gridCol = gridCol
    super.init(label:"\(gridRow+1)\(gridCol+1):\(digit)", digit:digit)
  }
  
  override func test_compatibility(with other:DLXNode)
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

class DLXOffGridRow : DLXRowNode
{
  /// Represents placing a given digit in an off-grid cell.
  /// Used to complete cages with less than 9 cells on the Sudoku grid
  let cage : Character
  let cageIndex : Int
  
  init(cage:Character, index:Int, digit:Int)
  {
    self.cage = cage
    self.cageIndex = index
    super.init(label:"\(cage)\(cageIndex+1):\(digit)", digit:digit)
  }

  override func test_compatibility(with other:DLXNode)
  {
    // only need to test other off-grid cells for same cage
    guard let other = other as? DLXOffGridRow,
          self.cage == other.cage,
          self.cageIndex != other.cageIndex
          else { return }
    
    if self.cageIndex < other.cageIndex,
       self.digit < other.digit { return }
    if self.cageIndex > other.cageIndex,
       self.digit > other.digit { return }
    
    self.incompatible.append(other)
    other.incompatible.append(self)
  }
}
