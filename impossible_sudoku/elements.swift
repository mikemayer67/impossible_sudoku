//
//  elements.swift
//  impossible_sudoku
//
//  Created by Mike Mayer on 1/18/22.
//

import Foundation

typealias Digits = Set<Int>
typealias Cells = Set<Int>

class Element
{
  let puzzle : Puzzle
  let label : String
  var complete : Bool { fatalError("abstract property") }
  
  init(_ puzzle:Puzzle, _ label:String) {
    self.puzzle = puzzle
    self.label = label
  }
}

class BasicElement : Element
{
  var coveredDigits = Digits()
  var availableCells : Array<Cells> // indexed by digit
  
  override var complete : Bool { return coveredDigits.count == 9 }
  
  init(_ puzzle: Puzzle, _ label:String, cells:Cells)
  {
    self.availableCells = Array<Cells>(repeating: cells, count: 9)
    super.init(puzzle,label)
  }
}

class Row : BasicElement
{
  let row : Int
  
  init(_ puzzle:Puzzle, _ row:Int) {
    self.row = row
    let cells = (0..<9).map({ 9*row + $0 })
    super.init(puzzle, "R\(row)", cells:Cells(cells))
  }
}

class Column : BasicElement
{
  let column : Int
  
  init(_ puzzle:Puzzle, _ column:Int) {
    self.column = column
    let cells = (0..<9).map({ 9*$0 + column })
    super.init(puzzle, "C\(column)", cells:Cells(cells))
  }
}

class Box : BasicElement
{
  let boxRow : Int
  let boxColumn : Int
  
  init(_ puzzle:Puzzle, _ box:Int) {
    let row = box / 3
    let col = box % 3
    self.boxRow = row
    self.boxColumn = col
    let cells = (0..<9).map({ 27*row + 9*($0 / 3) + 3*col + ($0 % 3) })
    super.init(puzzle, "B\(row)\(col)", cells: Cells(cells))
  }
}

class Cage : BasicElement
{
  let cage : Int
  let requiredDigts : Int
  
  override var complete: Bool { return coveredDigits.count == requiredDigts }
  
  init(_ puzzle:Puzzle, _ cage:Int)
  {
    self.cage = cage
    guard let coords = cageCoords[cage] else { fatalError("invalid cage: \(cage)")}
    self.requiredDigts = coords.count
    let cells = coords.map({ (r,c) -> Int in 9*r + c })
    super.init(puzzle, "\(cageLabels[cage])",cells:Cells(cells))
  }
}
