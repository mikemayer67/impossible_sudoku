//
//  debug.swift
//  impossible_sudoku
//
//  Created by Mike Mayer on 1/7/22.
//

import Foundation

func src()
{
  sr()
  sc()
  print("---------")
}
  
func sc()
{
  print("---------")
  for (i,c) in dlx.cols.enumerated() {
    let nodes = ColNodes(c).reduce("") {
      (r,n) -> String in
      r + " " + n.row.label
    }
    print("DLXCol \(i+1): \(c.label) [\(c.nrows):\(nodes)]")
  }
}

func sr()
{
  print("---------")
  for (i,r) in dlx.rows.enumerated() {
    let incomp = r.incompatible.reduce("") {
      (r,n) -> String in
      r + " " + n.label
    }
    let hiding = r.hiding.reduce("") {
     (r,n) -> String in
     r + " " + n.label
   }
    print("DLXRow \(i+1): \(r.label)  [\(incomp) |\(hiding) ]")
  }
}

func show_dlx(type:DLXColumnType, index:Int, digit:Int?=nil)
{
  var found = false
  for c in dlx.cols {
    if c.type == type, c.index == index {
      if digit == nil || c.digit == digit {
        let rows = ColNodes(c).reduce("") { (s, n) -> String in s + " \(n.row.label)" }
        print(" found \(c.label) [\(c.nrows)]: \(rows)")
        found = true
      }
    }
  }
  if !found { print(" not found") }
}

func show_dlx(col:Int, digit:Int?=nil) { show_dlx(type: .GridCol, index:col, digit: digit) }
func show_dlx(row:Int, digit:Int?=nil) { show_dlx(type: .GridRow, index:row, digit: digit) }
func show_dlx(box:Int, digit:Int?=nil) { show_dlx(type: .GridBox, index:box, digit: digit) }
func show_dlx(cage:Int, digit:Int?=nil) { show_dlx(type: .Cage, index:cage, digit: digit) }
