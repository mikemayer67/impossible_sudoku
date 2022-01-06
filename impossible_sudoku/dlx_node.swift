//
//  dlx_node.swift
//  impossible_sudoku
//
//  Created by Mike Mayer on 12/30/21.
//

import Foundation

class DLXNode {
  let label : String
  private(set) var nextRow : DLXNode!
  private(set) var nextCol : DLXNode!
  private(set) var prevRow : DLXNode!
  private(set) var prevCol : DLXNode!
  
  init(label:String)
  {
    self.label = label
    self.prevCol = self
    self.nextCol = self
    self.prevRow = self
    self.nextRow = self
  }
    
  func add(prevRow:DLXNode) { prevRow.insert(above:self) }
  func add(nextRow:DLXNode) { nextRow.insert(below:self) }
  func add(prevCol:DLXNode) { prevCol.insert(before:self) }
  func add(nextCol:DLXNode) { nextCol.insert(after:self) }
  
  func insert(after prevCol:DLXNode?=nil)
  {
    guard let left = prevCol else { return }
    guard self.prevCol === self, self.nextCol === self else {
      fatalError("Cannot insert DLX node into a row, prev/next column already set")
    }
    let right = left.nextCol!
    left.nextCol = self
    right.prevCol = self
    self.nextCol = right
    self.prevCol = left
  }
  
  func insert(before nextCol:DLXNode?=nil)
  {
    guard let right = nextCol else { return }
    guard self.prevCol === self, self.nextCol === self else {
      fatalError("Cannot insert DLX node into a row, prev/next column already set")
    }
    let left = right.prevCol!
    left.nextCol = self
    right.prevCol = self
    self.nextCol = right
    self.prevCol = left
  }
  
  func insert(below prevRow:DLXNode?=nil)
  {
    guard let up = prevRow else { return }
    guard self.prevRow === self, self.nextRow === self else {
      fatalError("Cannot insert DLX node into a column, prev/next row already set")
    }
    let down = up.nextRow!
    up.nextRow = self
    down.prevRow = self
    self.nextRow = down
    self.prevRow = up
  }
  
  func insert(above nextRow:DLXNode?=nil)
  {
    guard let down = nextRow else { return }
    guard self.prevRow === self, self.nextRow === self else {
      fatalError("Cannot insert DLX node into a column, prev/next row already set")
    }
    let up = down.prevRow!
    up.nextRow = self
    down.prevRow = self
    self.nextRow = down
    self.prevRow = up
  }
  
  func unlink(_ direction:GridDimension)
  {
    switch direction {
    case .Row:
      nextRow.prevRow = self.prevRow
      prevRow.nextRow = self.nextRow
    case .Col:
      nextCol.prevCol = self.prevCol
      prevCol.nextCol = self.nextCol
    }
  }
    
  func relink(_ direction:GridDimension)
  {
    switch direction {
    case .Row:
      nextRow.prevRow = self
      prevRow.nextRow = self
    case .Col:
      nextCol.prevCol = self
      prevCol.nextCol = self
    }
  }
  
  func test_compatibility(with other:DLXNode) {}
}
