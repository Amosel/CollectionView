import Foundation

class Node : Hashable, Equatable {
	init(name:String, type:NodeType, createChildren: () -> Set<Node>) {
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
        case normal = 1
        case important = 2
        case critical = 3
    }
	let nodeType:NodeType
    
    // setting the parent should be possible only internally.
    // do not set the parent extenally.
    weak var parent: Node? {
        didSet {
            parentHash = self.parent?.hashValue ?? 0
        }
    }
    
    func onChildrenChanged(_ new:Set<Node>,old:Set<Node>) {
        for child in old.filter( {!new.contains($0)} ) {
            child.parent = nil
        }
        for child in new {
            child.parent = self
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
    
    func walk(_ level:Int, visit: (_ node:Node,_ level:Int) -> ()) {
        visit(self,level)
        let nextLevel = level+1
        for each in self.children {
            each.walk(nextLevel, visit: visit)
        }
    }
    func walk(_ visit: (_ node:Node, _ level:Int) -> ()) {
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
    static func ==(lhs:Node, rhs:Node) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension Node {
    var byIndexPaths : [IndexPath : Node] {
        var mutable : [IndexPath : Node] = [:]
        self.walk({ (node, level) -> () in
            let indexPath = mutable.keys.nextIndexPathInSection(level)
            mutable[indexPath] = node
        })
        return mutable
    }

    var array : [[Node]] {
        var mutable = [[Node]]()
        self.walk({ (node, level) -> () in
            if mutable.count > level {
                mutable[level] = mutable[level]+[node]
            } else {
                mutable.append([node])
            }
        })
        return mutable
    }
}
