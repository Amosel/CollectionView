//: Playground - noun: a place where people can play

import Cocoa

let s = [1,2,3,4,5].flatMap { return [$0,$0*2,$0*3] }

s


extension NSIndexPath {
    
    convenience init(path:[Int]) {
        let buffer = UnsafeMutablePointer<Int>.alloc(path.count)
        for (index,pathElement) in path.enumerate() {
            buffer[index] = pathElement
        }
        self.init(indexes: buffer, length: path.count)
    }
    
    convenience init(row: Int, section: Int) {
        let path = [section, row]
        let buffer = UnsafeMutablePointer<Int>.alloc(path.count)
        for (index,pathElement) in path.enumerate() {
            buffer[index] = pathElement
        }
        self.init(indexes: buffer, length: path.count)
    }
}

let one = NSIndexPath(row: 3, section: 4)
one.section
one.item


extension CollectionType {
    typealias Element = Generator.Element
    
    func groupBy<Key : Hashable >(fn:(Element)->(Key)) -> [Key:[Element]] {
        typealias Bundle = [Key:[Element]]
        return reduce(Bundle()) { (var bundle, element) in
            let key = fn(element)
            if bundle[key] != nil {
                bundle[key]!.append(element)
            } else {
                bundle[key] = [element]
            }
            return bundle
        }
        
    }
    
    func groupBy<Key : Hashable, NewElement >(fn:(Element)->(Key,NewElement)) -> [Key:[NewElement]] {
        typealias Bundle = [Key:[NewElement]]
        return reduce(Bundle()) { (var bundle, element) in
            let (key, newElement) = fn(element)
            if bundle[key] != nil {
                bundle[key]!.append(newElement)
            } else {
                bundle[key] = [newElement]
            }
            return bundle
        }
    }
}

func testGroupBy() {
    let omg = [1,2,3,4,5,6].groupBy { $0 % 2}
    assert(omg == [0: [2, 4, 6], 1: [1, 3, 5]])
    
    let omfg = [1,2,3,4,5,6].groupBy { ($0 % 2, "\($0)") }
    assert(omfg == [0: ["2", "4", "6"], 1: ["1", "3", "5"]])
}

//testGroupBy()

typealias Item = (size: CGSize, parents: NSIndexSet)
let item = Item(size:CGSizeMake(100, 100),parents:NSIndexSet(index: 1))

var items = [Item(size:CGSizeMake(100, 100),parents:NSIndexSet(index: 1)),
            Item(size:CGSizeMake(90, 90),parents:NSIndexSet(index: 2))
]

let newSize = CGSizeMake(1, 1)
let newSizes = [(Int(0),newSize),(Int(1),newSize)]
for (index,size) in newSizes {
    items[index].size = size
}
assert(items[0].size == newSize)

items


let invalidatedSizesForIndexPaths: [NSIndexPath:CGSize] = [
    NSIndexPath(forItem: 0, inSection: 0): CGSizeMake(100, 100),
    NSIndexPath(forItem: 1, inSection: 0): CGSizeMake(90, 90)]


let o = invalidatedSizesForIndexPaths.map { [$0.section : [$0.item : $1]] }

let g = invalidatedSizesForIndexPaths.groupBy { ($0.section, [$0.item : $1]) }
let expectedG = [0 : [0: CGSizeMake(100, 100)], 1 : [0 : CGSizeMake(90, 90)] ]
//assert(g == expectedG)




//let g = invalidatedSizesForIndexPaths.groupBy { $0.section }

//let transaction = invalidatedSizesForIndexPaths.reduce([Int: [ Int: CGSize ] ](), combine: { (sum, pair) in
//    let (indexPath,size) = pair[0]
//    if let section = sum[pair.keys.array[0]] ?? [
//    return sum
//    })


struct Child <T>{
    typealias Item = T
    var items:[Item] {
        didSet {
            //print("changed:\(oldValue), \(items)")
        }
    }
}


typealias StringChilds = Child<String>
var t = StringChilds(items: ["First", "Second"])
t.items[0] = "Replace"
print(t)

let childs:[StringChilds] = [StringChilds(items: ["first", "second"]), StringChilds(items: ["One", "Two"])]

var parent = Child<StringChilds>(items: childs)

// this will change parent:
parent.items[0].items[0] = "Replace"

// this will not change parent:
var aChild = parent.items[0]
aChild.items[0] = "1234"

print(parent)

//var first:[[Int]] = [[1,2,3,4], [1,2,3,4], [1,2,3,4]]
//var second = first
//first[1].append(2)
//second


//class Node : Hashable, Equatable {
//	init(name:String, type:NodeType, @noescape createChildren: ()->Set<Node>) {
//		self.nodeType = type
//		self.name = name
//		self.children = createChildren()
//	}
//	init(name:String, type:NodeType) {
//		self.nodeType = type
//		self.name = name
//	}
//	let name:String
//	enum NodeType {
//		case Normal
//		case Important
//		case Critical
//	}
//	let nodeType:NodeType
//	var parent:Node?
//	var children = Set<Node>()
//	var hashValue: Int {
//		get {
//			return (self.name.hashValue << 16) + (self.children.reduce(Int()) { return $0 + $1.hashValue} << 8)
//		}
//	}
//
//    func walk(level:Int, @noescape visit:(node:Node,level:Int)->()) {
//        visit(node: self,level: level)
//        let nextLevel = level+1
//        for each in self.children {
//            each.walk(nextLevel, visit: visit)
//        }
//    }
//    func walk(@noescape visit:(node:Node, level:Int) -> ()) {
//        walk(0, visit: visit)
//    }
//}
//
//func ==(lhs:Node, rhs:Node) -> Bool {
//	return lhs.nodeType == rhs.nodeType && lhs.name == rhs.name && lhs.parent == rhs.parent && lhs.children == rhs.children
//}
//
//let tree = Node(name:"Root", type:.Normal)
//	{[
//		Node(name:"Child 1", type:.Normal)
//			{[
//				Node(name:"Child 1-1", type:.Important),
//				Node(name:"Child 1-2", type:.Critical)
//				]},
//		Node(name:"Child 2", type:.Normal),
//		Node(name:"Child 3", type:.Normal)
//			{[
//				Node(name:"Child 3-1", type:.Normal)
//					{[
//						Node(name:"Child 3-1-1", type:.Critical),
//						Node(name:"Child 3-1-2", type:.Normal)
//						]},
//				Node(name:"Child 3-2", type:.Important)
//				]}
//		]}
//
//var nodes = [[Node]]()
//
//func preorder_walk(node:Node?, level:Int, visit:(Node,level:Int)->())
//{
//    guard let node = node else {
//        return
//    }
//    visit(node,level: level)
//    let nextLevel = level+1
//    for each in node.children {
//        preorder_walk(each, level: nextLevel, visit: visit)
//    }
//}
//
//func preorder_visit(node:Node, level:Int) {
//    if nodes.count > level {
//        nodes[level] = nodes[level]+[node]
//    } else {
//        nodes.append([node])
//    }
//}
//
//func test_visit(node:Node, level:Int) {
//    print("\(level) node:\(nodes)")
//}
//
//preorder_walk(tree, level: 0, visit: preorder_visit)
//nodes

//
//
//protocol AllElements {
//	typealias ElementType
//	// Return an array containing all the objects
//	// in the collection
//	func allElements() -> Array<ElementType>
//}
//
//protocol NilLiteralConvertible {
//	static func convertFromNilLiteral() -> Self
//}
//
//func appendToArray<T: AllElements, U where U == T.ElementType>
//	(source: T, inout dest: Array<U>) {
//
//  let a = source.allElements()
//  for element in a {
//	dest.append(element)
//  }
//}
