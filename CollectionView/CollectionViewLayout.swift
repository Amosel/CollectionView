import UIKit

protocol CollectionViewLayoutMetrics {
    var sectionMargin: CGFloat { get }
    var nodeSize: CGSize { get }
    var sectionPadding: CGFloat { get }
    init()
}

protocol Child {
    associatedtype Parent
    var parent :Parent { get }
}

protocol HasSize {
    var size: CGSize { get }
}

enum SchematicItem : HasSize {
    case normal(CGSize, IndexSet)
    case connector(CGSize)
    var size: CGSize {
        switch self {
        case .normal(let size, _):
            return size
        case .connector(let size):
            return size
        }
    }
    var parents: IndexSet {
        switch self {
        case .normal(_, let parents):
            return parents
        default:
            return IndexSet()
        }
    }
}

func transform<T: HasSize> (_ sections: [[Node]]?, metrics:CollectionViewLayoutMetrics, toItems:@escaping (Int, Node) -> [T]) -> [SectionDescription<T>] {
    return sections?.mapWithIndex { (sectionIndex, nodes) in
        let sectionIndexFloat = CGFloat(sectionIndex)
        let offset = metrics.sectionMargin + (sectionIndexFloat * metrics.nodeSize.width) + (sectionIndexFloat * metrics.sectionPadding)
        let items:[SectionDescription.Item] = nodes.flatMapWithIndex(toItems)
        return SectionDescription(index: sectionIndex, offset: CGPoint(x:offset, y: 0), items: items)
        } ?? []
}


class CollectionViewLayout <M: CollectionViewLayoutMetrics> : UICollectionViewLayout {
    typealias SectionType = SectionDescription<SchematicItem>
    typealias Metrics = M
    
    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
	var sectionDescriptions: [SectionType]?

    var dataController : SchematicDataController?

    var metrics: Metrics = Metrics()
    {
        didSet {
            self.invalidateLayout()
        }
    }
    
    override func prepare() {
        // here the data we are dealing with is static, so the section description is only populated once.
        // when the data controller sections change, the section description should change too.
        self.sectionDescriptions = transform(dataController!.sections, metrics: metrics, toItems: { (sectionIndex, node) in
            let indexSet = NSMutableIndexSet()
            guard let parent = node.parent, let indexPath = self.dataController!.indexPath(for: parent) else {
                return [.normal(self.metrics.nodeSize,indexSet as IndexSet)]
            }
            indexSet.add(indexPath.item)
            return [.normal(self.metrics.nodeSize,indexSet as IndexSet)]
        })
    }
    
	// we need to cache all the layout information (in the SectionDescription struct is in order to get the content size for the scroll view.
	// we use the offset and size information of the section description to calculate the content size.
	override var collectionViewContentSize : CGSize {
		if let _ = self.dataController, let sectionDescriptions = self.sectionDescriptions {
			var width: CGFloat = 0.0
			if let lastSection = sectionDescriptions.last {
			    width = lastSection.frame.maxX + metrics.sectionMargin
			}
			let height = sectionDescriptions.map{ $0.size.height }.reduce(0.0,max)
			return CGSize(width: width, height: height)
		}
		return super.collectionViewContentSize
	}

    func sectionsInRect(_ rect:CGRect) -> [SectionType] {
        return self.sectionDescriptions?.filter { $0.offset.x >= rect.minX && $0.offset.x <= rect.maxX } ?? []
    }
	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
#if false
        return sectionsInRect(rect).flatMapWithIndex {sectionIndex, section -> [UICollectionViewLayoutAttributes] in
            return section.itemIndexesInRect(rect)
                // get the indexPaths
                .map { IndexPath(row: $0, section: sectionIndex) }
                // removes the optionsals:
                .flatMap(self.layoutAttributesForItemAtIndexPath)
        }
#else
        var attributes = [UICollectionViewLayoutAttributes]()
		if let sectionDescriptions = self.sectionDescriptions {
			attributes += sectionDescriptions.enumerated().flatMap {
				sectionIndex, section -> [UICollectionViewLayoutAttributes] in
				var items = [UICollectionViewLayoutAttributes]()
				if section.offset.x >= rect.minX && section.offset.x <= rect.maxX {
					items += section.items.enumerated().flatMap {
						itemIndex, item -> [UICollectionViewLayoutAttributes] in
						var itemAttributes = [UICollectionViewLayoutAttributes]()
                        if rect.contains(section.frameForItem(at: itemIndex)) {
							let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
                            print("indexPath: \(indexPath)")
							itemAttributes.append(self.layoutAttributesForItem(at: indexPath as IndexPath)!)
                            // add the connector view:
                            if let (nextSectionIndex, nextSection) = sectionDescriptions.optional(at:sectionIndex + 1) {
                                let children = nextSection.items.enumerated().filter() { childIndex, child in child.parents.contains(itemIndex) }
                                for (childIndex, _) in children {
                                    let indexPath = IndexPath(item: childIndex, section: nextSectionIndex)
                                    let t = self.layoutAttributesForSupplementaryView(ofKind: SchematicLayout.connectorViewKind, at:indexPath)
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

	override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		let attributes = SchematicLayoutAttributes(forCellWith: indexPath)
		if let sectionDescriptions = self.sectionDescriptions {
            attributes.frame = sectionDescriptions[indexPath.section].frameForItem(at: indexPath.item)
		}
		return attributes
	}
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
            let attributes = SchematicLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
            if let sectionDescriptions = self.sectionDescriptions, let dataController = self.dataController
            {
                let _ = dataController.element(at: indexPath)
                let childSectionDescription = sectionDescriptions[indexPath.section]
                let childFrame = childSectionDescription.frameForItem(at: indexPath.item)
                for parentIndex in childSectionDescription.items[indexPath.item].parents
                {
                    let parentIndexPath = IndexPath(item: parentIndex, section: indexPath.section - 1)
                    let parentFrame = sectionDescriptions[parentIndexPath.section].frameForItem(at: parentIndexPath.item)
                    let y = min(parentFrame.midY, childFrame.midY)
                    attributes.frame = CGRect(x: parentFrame.maxX, y: y, width: abs(childFrame.minX - parentFrame.maxX), height: abs(childFrame.midY - parentFrame.midY))
                    attributes.connectorLineStartTop = parentFrame.midY > childFrame.midY
                }
            }
            return attributes
    }
}


