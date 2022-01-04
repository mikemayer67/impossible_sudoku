//
//  dlx_head.swift
//  impossible_sudoku
//
//  Created by Mike Mayer on 1/1/22.
//

import Foundation

class DLXHeadNode : DLXNode
{
  var dlx_rows = Array<DLXRowNode>()
  var dlx_cols = Array<DLXColumnNode>()
  
  init() {
    super.init(label:"DLX Head")
    
    add_rows()
    add_cols()
  }
  
  func add(row:DLXRowNode)
  {
    self.add(prevRow: row)
    self.dlx_rows.append(row)
  }
  
  func add(col:DLXColumnNode)
  {
    self.add(prevCol: col)
    self.dlx_cols.append(col)
  }
  
  func add_rows()
  {
    // Add On-Grid DLX rows
    //  These respresent each possible digit placed on each possible Sudoku grid cell
    //  9 sudoku rows x 9 sudoku columns x 9 digits
    for r in 0..<9 {
      for c in 0..<9 {
        for d in 1...9 {
          self.add(row:DLXOnGridRow(gridRow: r, gridCol: c, digit: d))
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
        
    for (cage,coords) in cages {
      let r = self.prevRow!
      let ncoord = coords.count
      if ncoord == 9 { continue }
      let needed = 9 - ncoord
      for i in 0..<needed {
        for digit in 1+i...10-needed+i {
          self.add(row: DLXOffGridRow(cage:cage, index:i, digit:digit))
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
  
  func add_cols()
  {
    // Add DLX columns covering Sudoku grid rows
    for r in 0..<9 {
      for d in 1...9 {
        self.add(col: DLXColumnNode(gridRow: r, digit: d))
      }
    }
    // Add DLX columns covering Sudoku grid columns
    for c in 0..<9 {
      for d in 1...9 {
        self.add(col: DLXColumnNode(gridCol: c, digit: d))
      }
    }
    // Add DLX columns covering Sudoku grid boxes
    for b in 0..<9 {
      for d in 1...9 {
        self.add(col: DLXColumnNode(gridBox: b, digit: d))
      }
    }
    // Add DLX columns covering Sudoku cages
    for c in cages.keys.sorted() {
      for d in 1...9 {
        self.add(col: DLXColumnNode(cage: c, digit: d))
      }
    }
  }
}
