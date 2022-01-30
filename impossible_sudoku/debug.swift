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

func breakpoint(on key:String)
{
  if debug_on, breaking.contains(key)
  {
    print("breaking")
  }
}

func debug(_ level:Int = 0 , _ key:String, _ s:String)
{
  if debug_on, (watching.isEmpty || watching.contains(key)) {
    let indent = String(repeating: " ", count: level)
    print( "\(indent)\(key): \(s)")
  }
}

extension Puzzle
{
  func show_state()
  {
    print("\nDepth: \(self.solution.count)")
    print("+---+---+---+")
    for row in 0..<9 {
      var str = "|"
      for col in 0..<9 {
        if let digit = self.cells[9*row+col].digit {
          str += "\(digit+1)"
        }
        else {
          str += " "
        }
        if col%3==2 {str += "|"}
      }
      print(str)
      if row%3 == 2 { print("+---+---+---+")}
    }
  }
  
  func show_available()
  {
    let rowGap  = "|             |             |             |"
    let rowLine = "+-------------+-------------+-------------+"
    
    print ("")
    print(rowLine)
    for row in 0..<9 {
      for dr in 0..<3 {
        var str = "| "
        for col in 0..<9 {
          let cell = self.cells[9*row + col]
          for dc in 0..<3 {
            if let cd = cell.digit {
              str += ( dc==1 && dr == 1 ? "\(cd+1)" : " " )
            } else {
              let digit = 3*dr + dc
              if cell.availableDigits.contains(digit)
              {
                if !cell.row.coveredDigits.contains(digit),
                   !cell.col.coveredDigits.contains(digit),
                   !cell.box.coveredDigits.contains(digit),
                   cell.row.availableCells[digit].contains(cell),
                   cell.col.availableCells[digit].contains(cell),
                   cell.box.availableCells[digit].contains(cell)
                { str += "o"}
                else { str += "x"}
              }
              else
              {
                str += " "
              }
            }
            if dc%3 == 2 { str += (col%3 == 2 ? " | " : " ") }
          }
        }
        print(str)
        if dr%3 == 2 { print(row % 3 == 2 ? rowLine : rowGap) }
      }
    }
  }
}
