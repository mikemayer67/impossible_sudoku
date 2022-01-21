//
//  debug.swift
//  impossible_sudoku
//
//  Created by Mike Mayer on 1/7/22.
//

import Foundation

func debug(_ s:String) {
  if debug_on {
    print(s)
  }
}

func show_available(_ puzzle:Puzzle)
{
  for cell in puzzle.cells {
    let available = cell.availableDigits.sorted().reduce("") { (r, d) -> String in "\(r) \(d+1)" }
    print("Cell \(cell.label): \(available)")
  }
  print("-------")
  for row in puzzle.rows {
    for digit in 0..<9 {
      if !row.coveredDigits.contains(digit) {
        let available = row.availableCells[digit].sorted().reduce("") { (r, c) -> String in "\(r) \(c)" }
        print("Row \(row.label) - \(digit): \(available)")
      }
    }
  }
}
