//
//  dlx_head.swift
//  impossible_sudoku
//
//  Created by Mike Mayer on 1/1/22.
//

import Foundation

class DLXHeadNode : DLXNode
{
  init() {
    super.init(label:"DLX Head")
  }
  
  var solved : Bool { self.nextCol === self }
  
  func add_rows()
  {
    // Add On-Grid DLX rows
    //  These respresent each possible digit placed on each possible Sudoku grid cell
    //  9 sudoku rows x 9 sudoku columns x 9 digits
    for r in 0..<9 {
      for c in 0..<9 {
        for d in 1...9 {
          self.add(prevRow:DLXOnGridRow(gridRow: r, gridCol: c, digit: d))
        }
      }
    }
    
    // Add grid incompatibilites
    // No adjacent sudoku cells may contain subsequent digits
    for a in Rows(self) {
      for b in Rows(a) {
        a.test_compatibility(with: b)
      }
    }
    
    // Add Off-Grid DLX rows and incompatibilities
    //   They represent each possible digit placed on the "off grid" cells
    //   These are the cells used to hold any unused digits for each cage
    // For any given cage, the digits must appear in ascending order
    //   Cage[i].digit < Cage[>i].digit
        
    for cage in cageIndicies {
      guard let coords = cageCoords[cage] else { continue }
      
      let mark = self.prevRow!
      let ncoord = coords.count
      if ncoord == 9 { continue }
      let needed = 9 - ncoord
      for i in 0..<needed {
        for digit in 1+i...10-needed+i {
          self.add(prevRow: DLXOffGridRow(cage:cage, index:i, digit:digit))
        }
      }
      if needed == 1 { continue }
      for a in Rows(mark) {
        for b in Rows(a) {
          a.test_compatibility(with: b)
        }
      }
    }
  }
  
  func add_cols()
  {
    // Add DLX columns covering Sudoku grid rows
    for r in 0..<9 {
      for d in 1...9 {
        self.add(prevCol: DLXRowColumn(gridRow: r, digit: d))
      }
    }
    // Add DLX columns covering Sudoku grid columns
    for c in 0..<9 {
      for d in 1...9 {
        self.add(prevCol: DLXColumnColumn(gridCol: c, digit: d))
      }
    }
    // Add DLX columns covering Sudoku grid boxes
    for r in 0..<3 {
      for c in 0..<3 {
        for d in 1...9 {
          self.add(prevCol: DLXBoxColumn(boxRow: r, boxCol: c, digit: d))
        }
      }
    }
    // Add DLX columns covering Sudoku cages
    for cage in cageIndicies {
      for d in 1...9 {
        self.add(prevCol: DLXCageColumn(cage: cage, digit: d))
      }
    }
    // Add DLX columns for unique cell entry
    for r in 0..<9 {
      for c in 0..<9 {
        self.add(prevCol: DLXGridCellColumn(gridRow: r, gridCol: c))
      }
    }
    for (cage,coords) in cageCoords {
      let ncells = 9 - coords.count
      if ncells > 0 {
         for i in 0..<ncells {
          self.add(prevCol: DLXCageCellColumn(cage: cage, index: i))
        }
      }
    }
  }
}
