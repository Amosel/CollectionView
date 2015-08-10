//: Playground - noun: a place where people can play

import Cocoa

class Node : Hashable, Equatable {
	init(name:String, type:NodeType, @noescape createChildren: ()->Set<Node>) {
		self.nodeType = type
		self.name = name
		self.children = createChildren()
	}
	init(name:String, type:NodeType) {
		self.nodeType = type
		self.name = name
	}
	let name:String
	enum NodeType {
		case Normal
		case Important
		case Critical
	}
	let nodeType:NodeType
	var parent:Node?
	var children = Set<Node>()
	var hashValue: Int {
		get {
			return (self.name.hashValue << 16) + (self.children.reduce(Int()) { return $0 + $1.hashValue} << 8)
		}
	}
}

func ==(lhs:Node, rhs:Node) -> Bool {
	return lhs.nodeType == rhs.nodeType && lhs.name == rhs.name && lhs.parent == rhs.parent && lhs.children == rhs.children
}

let tree = Node(name:"Root", type:.Normal)
	{[
		Node(name:"Child 1", type:.Normal)
			{[
				Node(name:"Child 1-1", type:.Important),
				Node(name:"Child 1-2", type:.Critical)
				]},
		Node(name:"Child 2", type:.Normal),
		Node(name:"Child 3", type:.Normal)
			{[
				Node(name:"Child 3-1", type:.Normal)
					{[
						Node(name:"Child 3-1-1", type:.Critical),
						Node(name:"Child 3-1-2", type:.Normal)
						]},
				Node(name:"Child 3-2", type:.Important)
				]}
		]}

var nodes = [[Node]]()

func preorder_walk(node:Node?, level:Int, visit:(Node,level:Int)->())
{
    guard let node = node else {
        return
    }
    visit(node,level: level)
    let nextLevel = level+1
    for each in node.children {
        preorder_walk(each, level: nextLevel, visit: visit)
    }
}

func preorder_visit(node:Node, level:Int) {
    if nodes.count > level {
        nodes[level] = nodes[level]+[node]
    } else {
        nodes.append([node])
    }
}

func test_visit(node:Node, level:Int) {
    print("\(level) node:\(nodes)")
}

preorder_walk(tree, level: 0, visit: preorder_visit)
nodes

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
