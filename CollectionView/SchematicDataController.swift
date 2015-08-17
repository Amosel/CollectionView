import UIKit

func transform(tree:Node?) -> IndexPathMap<Node> {
    return IndexPathMap<Node> {
        var mutable = [NSIndexPath : Node]()
        tree?.walk({ (node, level) -> () in
            let indexPath = mutable.keys.nextIndexPathInSection(level)
            mutable[indexPath] = node
        })
        return mutable
    }
}

func transform(tree:Node?) -> [[Node]] {
    var nodes = [[Node]]()
    tree?.walk({ (node, level) -> () in
        if nodes.count > level {
            nodes[level] = nodes[level]+[node]
        } else {
            nodes.append([node])
        }
    })
    return nodes
}

class SchematicDataController : NSObject {
    
    typealias SectionMap = IndexPathMap<Node>
    var sectionsMap = SectionMap { () -> ([NSIndexPath : Node]) in
        return [:]
    }
    
    var tree: Node? {
        didSet {
            sectionsMap = transform(tree)
            sections = transform(tree)
        }
    }
	var sections = [[Node]]()
	var maxNodesInSection = 0

	func performFetch() {
		tree = Node(name:"Root", type:.Normal)
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
	}

	func nodeAtIndexPath(indexPath: NSIndexPath) -> Node? {
		if let section = self.sections.optionalElementAtIndex(indexPath.section) {
			return section.optionalElementAtIndex(indexPath.row)
		}
		return nil
	}
	func indexPathForNode(node: Node) -> NSIndexPath? {
		for (sectionIndex, section) in self.sections.enumerate() {
			for (itemIndex, item) in section.enumerate() {
				if node == item {
					return NSIndexPath(forItem: itemIndex, inSection: sectionIndex)
				}
			}
		}
		return nil
	}
}