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
  let reverse : Bool
  init(_ head:DLXNode, type:GridDimension, reverse:Bool = false) {
    self.type = type
    self.reverse = reverse
    switch (type,reverse) {
    case (.Row,false): self.firstNode = head.nextCol as? Element
    case (.Row,true):  self.firstNode = head.prevCol as? Element
    case (.Col,false): self.firstNode = head.nextRow as? Element
    case (.Col,true) : self.firstNode = head.prevRow as? Element
    }
  }
  func makeIterator() -> AnyIterator<Element> {
    var cur : Element? = self.firstNode
    let type = self.type
    let reverse = self.reverse
    return AnyIterator<Element> { () -> Element? in
      defer {
        switch (type,reverse) {
        case (.Row,false): cur = cur?.nextCol as? Element
        case (.Row,true):  cur = cur?.prevCol as? Element
        case (.Col,false): cur = cur?.nextRow as? Element
        case (.Col,true):  cur = cur?.prevRow as? Element
        }
      }
      return cur
    }
  }
}

class RowNodes : NodeSequence {
  init(_ head:DLXNode, reverse:Bool=false) {
    super.init(head, type:.Row, reverse:reverse)
  }
}

class ColNodes : NodeSequence {
  init(_ head:DLXNode, reverse:Bool=false) {
    super.init(head, type:.Col, reverse:reverse)
  }
}
