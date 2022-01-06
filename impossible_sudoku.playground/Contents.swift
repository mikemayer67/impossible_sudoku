import Foundation

let x =
  "AAADDDGGG" +
  "A BDEDGHG" +
  "AABDEGGHH" +
  "AABDEEG H" +
  "BBBDDEEJH" +
  "BCBBF FJH" +
  "CCCCFFFJJ" +
  "C C F FJJ" +
  "C CFF JJJ"

func f(_ c:Character) -> Int?
{
  switch(c) {
  case "A"..."H":
    return Int(c.unicodeScalars.first!.value - Unicode.Scalar("A").value)
  case "J":
    return 8
  default:
    return nil
  }
}

let y = x.reduce(Array<Int?>()) { (r, c) in r + [f(c)] }

print(y)

