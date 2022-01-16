//
//  sequences.swift
//  impossible_sudoku
//
//  Created by Mike Mayer on 1/6/22.
//

import Foundation

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

class Rows : Sequence {
  typealias Element = DLXCoverNode
  let firstRow : Element?
  let reverse : Bool
  init(_ col:DLXColumnNode, reverse:Bool = false) {
    self.reverse = reverse
    switch reverse {
    case false: firstRow = col.nextRow as? Element
    case true:  firstRow = col.prevRow as? Element
    }
  }
  func makeIterator() -> AnyIterator<Element> {
    var cur : Element? = self.firstRow
    return AnyIterator<Element> { () -> Element? in
      defer {
        switch self.reverse {
        case false: cur = cur?.nextRow as? Element
        case true:  cur = cur?.prevRow as? Element
        }
      }
      return cur
    }
  }
}

class RowNodes : Sequence {
  typealias Element = DLXCoverNode
  let firstNode : Element?
  let lastNode : Element?
  let reverse : Bool
  init(_ rowNode:DLXCoverNode, reverse:Bool = false) {
    self.reverse = reverse
    self.lastNode = rowNode
    switch reverse {
    case false: self.firstNode = rowNode.nextCol as? DLXCoverNode
    case true:  self.firstNode = rowNode.prevCol as? DLXCoverNode
    }
  }
  init(_ row:DLXRow) {
    self.reverse = false
    self.firstNode = row.firstNode
    self.lastNode = row.firstNode
  }
  func makeIterator() -> AnyIterator<Element>  {
    var cur : Element? = self.firstNode
    return AnyIterator<Element> { () -> Element? in
      defer {
        switch self.reverse {
        case false: cur = cur?.nextCol as? DLXCoverNode
        case true:  cur = cur?.prevCol as? DLXCoverNode
        }
        if cur === self.lastNode { cur = nil }
      }
      return cur
    }
  }
}
