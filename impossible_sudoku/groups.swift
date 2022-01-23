//
//  groups.swift
//  impossible_sudoku
//
//  Created by Mike Mayer on 1/18/22.
//

import Foundation

typealias Digits = Set<Int>
typealias Cells = Set<Cell>

class Element
{
  let label : String
  var complete : Bool { fatalError("abstract property") }
  
  init(_ label:String) {
    self.label = label
  }
}

class CellGroup : Element
{
  var coveredDigits = Digits()
  var availableCells : Array<Cells> // indexed by digit
  
  override var complete : Bool { return coveredDigits.count == 9 }
  
  override init(_ label:String)
  {
    self.availableCells = Array<Cells>(repeating: Cells(), count: 9)
    super.init(label)
  }
  
  func link(_ cell:Cell)
  {
    for digit in 0..<9 {
      self.availableCells[digit].insert(cell)
    }
  }
}

class Row : CellGroup
{
  let row : Int
  
  init(_ row:Int) {
    self.row = row
    super.init("R\(row)")
  }
}

class Column : CellGroup
{
  let column : Int
  
  init(_ column:Int) {
    self.column = column
    super.init("C\(column)")
  }
}

class Box : CellGroup
{
  let boxRow : Int
  let boxColumn : Int
  
  init(_ box:Int) {

    self.boxRow = box/3
    self.boxColumn = box%3
    super.init("B\(self.boxRow)\(self.boxColumn)")
  }
}

class Cage : CellGroup
{
  let cage : Int
  let requiredDigts : Int
  
  override var complete: Bool { return coveredDigits.count == requiredDigts }
  
  init(_ cage:Int)
  {
    self.cage = cage
    guard let coords = cageCoords[cage] else { fatalError("invalid cage: \(cage)")}
    self.requiredDigts = coords.count
    super.init("\(cageLabels[cage])")
  }
}
