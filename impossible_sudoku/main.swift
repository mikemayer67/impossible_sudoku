//
//  main.swift
//  impossible_sudoku
//
//  Created by Mike Mayer on 12/30/21.
//

import Foundation

// This is an attempt to solve the modified sudoku problem featured in:
// https://www.youtube.com/watch?v=wO1G7GkIrWE
//
// It starts with a normal sudoku grid, with some twists:
//   There is a single starting digit:  (6,3) is set to 2
//   It adds 9 "cages" of length 7-9 cells in the sudoku grid
//     - each digit may appear only once in a given cage
//     - each cage containsn 7-9 cells in the sudoku grid
//     - figure below shows the cages labeled A,B,C,D,E,F,G,H,J
//   No adjacent sudoku cells may contain subsequent digits
//
//   A A A|D D D|G G G
//   A   B|D E D|G H G
//   A A B|D E G|G H H
//   -----+-----+-----
//   A A B|D E E|G   H
//   B B B|D D E|E J H
//   B C B|B F  |F J H
//   -----+-----+-----
//   C C C|C F F|F J J
//   C   C|  F  |F J J
//   C   C|F F  |J J J
//
// Solution approach
//   Modified Dancing Links (DLX)
//   - standard DLX algorithm works for the traditional rules
//   - modified DLX algorithm can be made to work for cages
//     - add "off grid" cells to hold digits for cages with less than 9 cells on the grid
//     - requires rule(*1) to enure uniqueness of off grid cells (enforce ascending order)
//   - modified DLX algorithm can be made to work for non-subsequent digits in adjacent cells
//     - requires rule(*2) to ensure non-subsequent digits in adjacent cells
//   Row Consistency Rules
//   - identifies pairs of rows in the DLX grid that cannot both be part of the solution
//     - allowed by traditional sudoku rules
//     - disallowed by rules for this particular puzzle
//   - examples
//     - 1: sorted off-grid cells: (cage=F1,digit=7) and (cage=F2,digit=4)
//     - 2: subsequent digits in adjacent cells: (row=8,col=7,digit=6) and (row=8,col=6,digit=5)

// DLX Head Node
let dlx = DLX()

dlx.add_given(row: 6, col: 3, digit: 2)
dlx.solve()
