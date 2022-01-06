//
//  cages.swift
//  impossible_sudoku
//
//  Created by Mike Mayer on 1/1/22.
//

import Foundation

typealias Coord = (row:Int,col:Int)
typealias Coords = Array<Coord>
typealias CageDef = Array<Array<Int?>>
typealias CageCoords = Dictionary<Int,Coords>

let cageDef : CageDef = [
   [ 0 , 0 , 0 , 3 , 3 , 3 , 6 , 6 , 6 ] , 
   [ 0 ,nil, 1 , 3 , 4 , 3 , 6 , 7 , 6 ] , 
   [ 0 , 0 , 1 , 3 , 4 , 6 , 6 , 7 , 7 ] , 
   [ 0 , 0 , 1 , 3 , 4 , 4 , 6 ,nil, 7 ] , 
   [ 1 , 1 , 1 , 3 , 3 , 4 , 4 , 8 , 7 ] , 
   [ 1 , 2 , 1 , 1 , 5 ,nil, 5 , 8 , 7 ] , 
   [ 2 , 2 , 2 , 2 , 5 , 5 , 5 , 8 , 8 ] , 
   [ 2 ,nil, 2 ,nil, 5 ,nil, 5 , 8 , 8 ] , 
   [ 2 ,nil, 2 , 5 , 5 ,nil, 8 , 8 , 8 ] , 
]

let cageCoords : CageCoords = {
  var cc = CageCoords()
  for (row,cols) in cageDef.enumerated() {
    for (col,cage) in cols.enumerated() {
      if let cage = cage {
        if cc[cage] == nil { cc[cage] = Coords() }
        cc[cage]!.append(Coord(row,col))
      }
    }
  }
  return cc
}()

let cageIndicies = cageCoords.keys.sorted()
let cageCount = cageIndicies.count

let cageLabels = Array("ABCDEFGHJKLMNPQRST")
