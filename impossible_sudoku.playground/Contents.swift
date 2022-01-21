import Foundation

class X {
  let x : Int
  init?(_ v:Int) {
    guard v>0 else { return nil }
    self.x = v
  }
}

if let x1 = X(1) {
  print(x1.x)
} else {
  print("NO X1")
}

if let x2 = X(0) {
  print(x2.x)
} else {
  print("NO X2")
}
