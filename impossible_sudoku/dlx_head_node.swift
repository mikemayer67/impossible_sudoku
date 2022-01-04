//
//  dlx_head_node.swift
//  impossible_sudoku
//
//  Created by Mike Mayer on 1/1/22.
//

import Foundation

class DLXHeadNode : DLXNode
{
  init() {
    super.init(label:"DLX Head")
    
    add_rows()
  }

  func add_rows()
  {
    // Add On-Grid DLX rows
    //  These respresent each possible digit placed on each possible Sudoku grid cell
    //  9 sudoku rows x 9 sudoku columns x 9 digits
    for r in 0..<9 {
      for c in 0..<9 {
        for d in 1...9 {
          self.add(prevRow: DLXOnGridRow(gridRow: r, gridCol: c, digit: d))
        }
      }
    }
    
    // Add grid incompatibilites
    // No adjacent sudoku cells may contain subsequent digits
    var a = self.nextRow!
    while a is DLXOnGridRow {
      var b = a.nextRow!
      while b is DLXOnGridRow {
        a.test_compatibility(with: b)
        b = b.nextRow
      }
      a = a.nextRow!
    }
    
    // Add Off-Grid DLX rows and incompatibilities
    //   They represent each possible digit placed on the "off grid" cells
    //   These are the cells used to hold any unused digits for each cage
    // For any given cage, the digits must appear in ascending order
    //   Cage[i].digit < Cage[>i].digit
    
    let cages = gen_cages()
    
    for (cage,coords) in cages {
      let r = self.prevRow!
      let ncoord = coords.count
      if ncoord == 9 { continue }
      let needed = 9 - ncoord
      for i in 0..<needed {
        for digit in 1+i...10-needed+i {
          self.add(prevRow: DLXOffGridRow(cage:cage, index:i, digit:digit))
        }
      }
      if needed == 1 { continue }
      var a = r.nextRow!
      while a is DLXOffGridRow {
        var b = a.nextRow!
        while b is DLXOffGridRow {
          a.test_compatibility(with: b)
          b = b.nextRow
        }
        a = a.nextRow!
      }
    }
  }
  
  var first_row : DLXRowNode {
    return self.nextRow as! DLXRowNode
  }
}
