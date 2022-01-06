import Foundation

class Node {
    var data: Int
    var next: Node?
    init(data: Int, next: Node?) {
        self.data = data
        self.next = next
    }
}

class LinkedList: Sequence {
    typealias Element = Node
    func next() -> Node? {
        defer {
            head = head?.next
        }
        return head
    }

    var head: Node?
    init(head: Node) {
        self.head = head
    }
    
}

let tail = Node(data: 3, next: nil)
let mid  = Node(data: 2, next: tail)
let head = Node(data: 1, next: mid)
let list = LinkedList(head: head)

print("First Iter")
for x in list { print(x.data) }

print("\nSecond Iter")
for x in list { print(x.data) }
