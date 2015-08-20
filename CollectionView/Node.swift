import Foundation

class Node : Hashable, Equatable {
	init(name:String, type:NodeType, @noescape createChildren: ()->Set<Node>) {
		self.nodeType = type
		self.name = name
		self.children = createChildren()
        onChildrenChanged(self.children, old: Set<Node>())
	}
	init(name:String, type:NodeType) {
		self.nodeType = type
		self.name = name
        self.children = Set<Node>()
	}
	let name:String
    enum NodeType : Int {
        case Normal = 1
        case Important = 2
        case Critical = 3
    }
	let nodeType:NodeType
    
    // setting the parent should be possible only internally.
    // do not set the parent extenally.
    weak var parent:Node?
    
    func onChildrenChanged(new:Set<Node>,old:Set<Node>) {
        for child in old.filter( {!new.contains($0)} ) {
            child.parent = nil
            child.parentHash = 0
        }
        for (index,child) in new.enumerate() {
            child.parent = self
            child.parentHash = self.hashValue + index
        }
    }
    
    var children : Set<Node> {
        didSet {
            onChildrenChanged(children, old: oldValue)
        }
    }
    var parentHash:Int = 0
    
    var hashValue: Int {
        get {
            return parentHash ^  self.children.hashValue ^ nodeType.hashValue ^ (name.hashValue << 8)
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
    
    var groupByLevel : [Int:[Node]]  {
        var mutable = [Int:[Node]]()
        walk { node, level in
            if var nodes:[Node] = mutable[level] {
                nodes.append(node)
            } else {
                mutable[level] = [node]
            }
        }
        return mutable
    }

}

func ==(lhs:Node, rhs:Node) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

