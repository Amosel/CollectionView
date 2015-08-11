import Foundation

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
    
    func walk(level:Int, @noescape visit:(node:Node,level:Int)->()) {
        visit(node: self,level: level)
        let nextLevel = level+1
        for each in self.children {
            each.walk(nextLevel, visit: visit)
        }
    }
    func walk(@noescape visit:(node:Node, level:Int) -> ()) {
        walk(0, visit: visit)
    }
}

func ==(lhs:Node, rhs:Node) -> Bool {
	return lhs.nodeType == rhs.nodeType && lhs.name == rhs.name && lhs.parent == rhs.parent && lhs.children == rhs.children
}

