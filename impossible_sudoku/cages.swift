//
//  cages.swift
//  impossible_sudoku
//
//  Created by Mike Mayer on 1/1/22.
//

import Foundation

typealias GridCoord = (Int,Int)
typealias GridCoords = Array<GridCoord>
typealias Cages = Dictionary<Character,GridCoords>

let cageCodes = Array("ABCDEFGHJ")
let cageIndices : Dictionary<Character,Int> = {
  var xref = Dictionary<Character,Int>()
  for (i,c) in cageCodes.enumerated() { xref[c] = i }
  return xref
}()

let cages : Cages = {
  let grid_coloring = [
    "AAADDDGGG",
    "A BDEDGHG",
    "AABDEGGHH",
    "AABDEEG H",
    "BBBDDEEJH",
    "BCBBF FJH",
    "CCCCFFFJJ",
    "C C F FJJ",
    "C CFF JJJ"
  ]
  
  var rval = Cages()
  for (r,s) in grid_coloring.enumerated() {
    for (c,cage) in s.enumerated() {
      if cage == " " { continue }
      if var coords = rval[cage] {
        coords.append((r,c))
        rval.updateValue(coords, forKey: cage)
      } else {
        let coords = [(r,c)]
        rval.updateValue(coords, forKey: cage)
      }
    }
  }
  return rval
}()

