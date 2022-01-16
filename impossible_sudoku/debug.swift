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

func show_all()
{
  show_rows()
  show_cols()
  print("---------")
}
  
func show_cols()
{
  print("---------")
  for (i,c) in dlx.cols.enumerated() {
    let nodes = Rows(c).reduce("") {
      (r,n) -> String in
      r + " " + n.row.label
    }
    print("DLXCol \(i+1): \(c.label) [\(c.nrows):\(nodes)]")
  }
}

func show_rows()
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
    print("DLXRow \(i+1): \(r.label)  \(r.hidden ? "X" : " ") [\(incomp) |\(hiding) ]")
  }
}
