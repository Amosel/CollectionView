import UIKit

protocol CollectionGeometry {
    var sectionMargin:CGFloat { get }
    var nodeSize:CGSize { get }
    var sectionPadding:CGFloat { get }
}

protocol Child {
    typealias Parent
    var parent :Parent { get }
}

enum SchematicItem : HasSize {
    case Normal(CGSize, NSIndexSet)
    case Connector(CGSize)
    var size:CGSize {
        switch self {
        case .Normal(let size, _):
            return size
        case .Connector(let size):
            return size
        }
    }
    var parents:NSIndexSet {
        switch self {
        case .Normal(_, let parents):
            return parents
        default:
            return NSIndexSet()
        }
    }
}

typealias SchematicSection = SectionDescription<SchematicItem>

func transform<T: HasSize> (sections:[[Node]]?, geometry:CollectionGeometry, toItems:(Int,Node)->[T]) -> [SectionDescription<T>] {
    return sections?.mapWithIndex { (sectionIndex, nodes) in
        let sectionIndexFloat = CGFloat(sectionIndex)
        let offset = geometry.sectionMargin + (sectionIndexFloat * geometry.nodeSize.width) + (sectionIndexFloat * geometry.sectionPadding)
        let items:[SectionDescription.Item] = nodes.flatMapWithIndex(toItems)
        return SectionDescription(index: sectionIndex, offset: offset, items: items)
    } ?? []
}

func transform<T:HasSize>(sections:[SectionDescription<T>]) -> [UICollectionViewLayoutAttributes] {
    return []
}

//
class CollectionViewLayout : UICollectionViewLayout {
    typealias SectionType = SectionDescription<SchematicItem>
	var sectionDescriptions:[SectionType]?
	var dataController : SchematicDataController?
    struct Geometry : CollectionGeometry {
        var sectionMargin:CGFloat = 12
        var nodeSize = CGSizeMake(100, 100)
        var sectionPadding:CGFloat = 30
    }
    var geometry = Geometry() {
        didSet {
            self.invalidateLayout()
        }
    }
    
    override func prepareLayout() {
        // here the data we are dealing with is static, so the section description is only populated once.
        // when the data controller sections change, the section description should change too.
        self.sectionDescriptions = transform(dataController?.sections, geometry: geometry, toItems: { (sectionIndex, node) in
            let indexSet = NSMutableIndexSet()
            guard let parent = node.parent, indexPath = self.dataController!.indexPathForNode(parent) else {
                return [.Normal(self.geometry.nodeSize,indexSet)]
            }
            indexSet.addIndex(indexPath.item)
            return [.Normal(self.geometry.nodeSize,indexSet)]
        })
    }
	// we need to cache all the layout information (in the SectionDescription struct is in order to get the content size for the scroll view.
	// we use the offset and size information of the section description to calculate the content size.
	override func collectionViewContentSize() -> CGSize {
		if let _ = self.dataController, sectionDescriptions = self.sectionDescriptions {
			var width: CGFloat = 0.0
			if let lastSection = sectionDescriptions.last {
			    width = lastSection.maxX + geometry.sectionMargin
			}
			let height = sectionDescriptions.map{ $0.size.height }.reduce(0.0,combine: max)
			return CGSize(width: width, height: height)
		}
		return super.collectionViewContentSize()
	}

    func sectionsInRect(rect:CGRect) -> [SectionType] {
        return self.sectionDescriptions?.filter { $0.offset >= rect.minX && $0.offset <= rect.maxX } ?? []
    }
	override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
#if false
        return sectionsInRect(rect).flatMapWithIndex {sectionIndex, section -> [UICollectionViewLayoutAttributes] in
            return section.itemIndexesInRect(rect)
                // get the indexPaths
                .map { NSIndexPath(row: $0, section: sectionIndex) }
                // removes the optionsals:
                .flatMap(self.layoutAttributesForItemAtIndexPath)
        }
#else
        var attributes = [UICollectionViewLayoutAttributes]()
		if let sectionDescriptions = self.sectionDescriptions {
			attributes += sectionDescriptions.enumerate().flatMap {
				sectionIndex, section -> [UICollectionViewLayoutAttributes] in
				var items = [UICollectionViewLayoutAttributes]()
				if section.offset >= rect.minX && section.offset <= rect.maxX {
					items += section.items.enumerate().flatMap {
						itemIndex, item -> [UICollectionViewLayoutAttributes] in
						var itemAttributes = [UICollectionViewLayoutAttributes]()
						if rect.contains(section.frameForItemAtIndex(itemIndex)) {
							let indexPath = NSIndexPath(forItem: itemIndex, inSection: sectionIndex)
							itemAttributes.append(self.layoutAttributesForItemAtIndexPath(indexPath)!)
                            // add the connector view:
                            let nextSectionIndex = sectionIndex + 1
                            if let nextSection = sectionDescriptions.optionalElementAtIndex(nextSectionIndex) {
                                let children = nextSection.items.enumerate().filter() { childIndex, child in child.parents.containsIndex(itemIndex) }
                                for (childIndex, _) in children {
                                    let indexPath = NSIndexPath(forItem: childIndex, inSection: nextSectionIndex)
                                    let t = self.layoutAttributesForSupplementaryViewOfKind(SchematicLayout.connectorViewKind, atIndexPath:indexPath)
                                    itemAttributes.append(t!)
                                }
                            }
						}
						return itemAttributes
					}
				}
				return items
			}
		}
        return attributes
#endif
	}

	override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
		let attributes = SchematicLayoutAttributes(forCellWithIndexPath: indexPath)
		if let sectionDescriptions = self.sectionDescriptions {
			attributes.frame = sectionDescriptions[indexPath.section].frameForItemAtIndex(indexPath.item)
		}
		return attributes
	}
    
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
            let attributes = SchematicLayoutAttributes(forSupplementaryViewOfKind: elementKind, withIndexPath: indexPath)
            if let sectionDescriptions = self.sectionDescriptions, dataController = self.dataController
            {
                let node = dataController.nodeAtIndexPath(indexPath)
                let childSectionDescription = sectionDescriptions[indexPath.section]
                let childFrame = childSectionDescription.frameForItemAtIndex(indexPath.item)
                for parentIndex in childSectionDescription.items[indexPath.item].parents
                {
                    let parentIndexPath = NSIndexPath(forItem: parentIndex, inSection: indexPath.section - 1)
                    let parentFrame = sectionDescriptions[parentIndexPath.section].frameForItemAtIndex(parentIndexPath.item)
                    let y = min(parentFrame.midY, childFrame.midY)
                    attributes.frame = CGRect(x: parentFrame.maxX, y: y, width: abs(childFrame.minX - parentFrame.maxX), height: abs(childFrame.midY - parentFrame.midY))
                    attributes.connectorLineStartTop = parentFrame.midY > childFrame.midY
                }
            }
            return attributes
    }
}


