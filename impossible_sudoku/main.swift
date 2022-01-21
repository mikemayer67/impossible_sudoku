//
//  main.swift
//  impossible_sudoku
//
//  Created by Mike Mayer on 12/30/21.
//

import Foundation

// This is an attempt to solve the modified sudoku problem featured in:
// https://www.youtube.com/watch?v=wO1G7GkIrWE.  This is actually the
// second attempt.  The first was a modified DLX algorithm that didn't
// pan out.
//
// The puzzle starts with a normal sudoku grid, with some twists:
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
//   A slightly less than brute-force search with backtracking.
//
//   In reality this method is not terribly different from the DLX algorithm,
//     but without trying to force the puzzle variations onto the standard
//     sudoku DLX algorithm.  There were two gotchas with using the DLX
//     algorithm.
//     - it cannot account for non-sequential neighboring cells (i.e. no notion of inconsidtent rows)
//     - it cannot handle cages with less than the full set of 9 digits (i.e. no notion of partial coverage)
//
//   What will be kept from DLX
//     - the notion of objectives (DLX columns)
//     - the notion of actions (DLX rows)
//     - search tree based on minimizing number of forks at each node

let debug_on = false
let watching = ["C8=3","J=3","46:3"]

let puzzle = Puzzle()
puzzle.add(row: 6, col: 3, digit: 1) // remember that our puzzle uses 0-8 rather than 1-9

show_available(puzzle)

print("ok")
