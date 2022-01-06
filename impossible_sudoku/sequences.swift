//
//  sequences.swift
//  impossible_sudoku
//
//  Created by Mike Mayer on 1/6/22.
//

import Foundation

class Rows : Sequence {
  typealias Element = DLXRowNode
  let firstRow : Element?
  init(_ head:DLXNode) { self.firstRow = head.nextRow as? Element }
  func makeIterator() -> AnyIterator<Element> {
    var cur : Element? = self.firstRow
    return AnyIterator<Element> { () -> Element? in
      defer { cur = cur?.nextRow as? Element }
      return cur
    }
  }
}

class Cols : Sequence {
  typealias Element = DLXColumnNode
  let firstCol : Element?
  init(_ head:DLXNode) { self.firstCol = head.nextCol as? Element }
  func makeIterator() -> AnyIterator<Element> {
    var cur : Element? = self.firstCol
    return AnyIterator<Element> { () -> Element? in
      defer { cur = cur?.nextCol as? Element }
      return cur
    }
  }
}

class NodeSequence : Sequence {
  typealias Element = DLXCoverNode
  let firstNode : Element?
  let type : GridDimension
  init(_ head:DLXNode, type:GridDimension) {
    self.type = type
    switch type {
    case .Row: self.firstNode = head.nextCol as? Element
    case .Col: self.firstNode = head.nextRow as? Element
    }
  }
  func makeIterator() -> AnyIterator<Element> {
    var cur : Element? = self.firstNode
    let type = self.type
    return AnyIterator<Element> { () -> Element? in
      defer {
        switch type {
        case .Row: cur = cur?.nextCol as? Element
        case .Col: cur = cur?.nextRow as? Element
        }
      }
      return cur
    }
  }
}

class RowNodes : NodeSequence { init(_ head:DLXNode) { super.init(head, type: .Row) } }
class ColNodes : NodeSequence { init(_ head:DLXNode) { super.init(head, type: .Col) } }
