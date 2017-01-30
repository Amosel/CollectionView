import UIKit

class SchematicDataController : NSObject, LayoutDataControllerProtocol {

    typealias SectionMap = IndexPathMap<Node>
    var sectionsMap = SectionMap {
        return [:]
    }
    var sections = [[Node]]()

    var tree: Node? {
        didSet {
            sectionsMap = IndexPathMap {
                tree?.byIndexPaths ?? [:]
            }
            sections = tree?.array ?? []
        }
    }
	var maxNodesInSection = 0

	func performFetch() {
		tree = Node(name:"Root", type:.normal)
		{[
			Node(name:"Child 1", type:.normal)
			{[
					Node(name:"Child 1-1", type:.important),
					Node(name:"Child 1-2", type:.critical)
			]},
			Node(name:"Child 2", type:.normal),
			Node(name:"Child 3", type:.normal)
			{[
				Node(name:"Child 3-1", type:.normal)
				{[
					Node(name:"Child 3-1-1", type:.critical),
					Node(name:"Child 3-1-2", type:.normal)
				]},
				Node(name:"Child 3-2", type:.important)
			]}
		]}
	}

	func element(at indexPath: IndexPath) -> Node? {
        return self.sectionsMap.element(at: indexPath)
	}

	func indexPath(for element: Node) -> IndexPath? {
        return self.sectionsMap.indexPath(for: element)
	}
    
    func indexPathForParent(for element:Node) -> IndexPath? {
        if let parent = element.parent {
            return self.indexPath(for: parent)
        }
        return nil
    }
}
