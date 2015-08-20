import UIKit

protocol CollectionViewLayoutMetrics {
    var sectionMargin:CGFloat { get }
    var nodeSize:CGSize { get }
    var sectionPadding:CGFloat { get }
    init()
}

protocol Child {
    typealias Parent
    var parent :Parent { get }
}

protocol HasSize {
    var size:CGSize { get }
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

func transform<T: HasSize> (sections:[[Node]]?, metrics:CollectionViewLayoutMetrics, toItems:(Int,Node)->[T]) -> [SectionDescription<T>] {
    return sections?.mapWithIndex { (sectionIndex, nodes) in
        let sectionIndexFloat = CGFloat(sectionIndex)
        let offset = metrics.sectionMargin + (sectionIndexFloat * metrics.nodeSize.width) + (sectionIndexFloat * metrics.sectionPadding)
        let items:[SectionDescription.Item] = nodes.flatMapWithIndex(toItems)
        return SectionDescription(index: sectionIndex, offset: offset, items: items)
    } ?? []
}

func transform<T:HasSize>(sections:[SectionDescription<T>]) -> [UICollectionViewLayoutAttributes] {
    return []
}

//
class CollectionViewLayout <M:CollectionViewLayoutMetrics> : UICollectionViewLayout {
    typealias SectionType = SectionDescription<SchematicItem>
    typealias Metrics = M
    
    override init() {
        super.init()
    }
    
	var sectionDescriptions:[SectionType]?
    var dataController : SchematicDataController?
    var metrics:Metrics = Metrics()
    {
        didSet {
            self.invalidateLayout()
        }
    }
    
    func sectionsInRect(rect:CGRect) -> [SectionType]
    {
        return self.sectionDescriptions?.filter { $0.offset >= rect.minX && $0.offset <= rect.maxX } ?? []
    }
    
    func indexPathsForItemsInRect(rect:CGRect) -> [NSIndexPath]
    {
        return sectionsInRect(rect).flatMapWithIndex
            { sectionIndex, section in
                return section.itemIndexesInRect(rect).map { NSIndexPath(row: $0, section: sectionIndex) }
        }
    }
    
    
    func indexPathsForChildrenOfItemAtIndexPath(indexPath:NSIndexPath) -> [NSIndexPath]
    {
        let sectionIndex = indexPath.section
        let itemIndex = indexPath.item
        let nextSectionIndex = sectionIndex + 1
        return self.sectionDescriptions?.optionalElementAtIndex(nextSectionIndex)?.items
            .filter { $0.parents.containsIndex(itemIndex) }
            .mapWithIndex { (childIndex, _) -> NSIndexPath in
                return NSIndexPath(forItem: childIndex, inSection: nextSectionIndex)
            } ?? []
    }
    

    override func prepareLayout() {
        // here the data we are dealing with is static, so the section description is only populated once.
        // when the data controller sections change, the section description should change too.
        self.sectionDescriptions = transform(dataController?.sections, metrics: metrics, toItems: { (sectionIndex, node) in
            let indexSet = NSMutableIndexSet()
            guard let parent = node.parent, indexPath = self.dataController!.indexPathForNode(parent) else
            {
                return [.Normal(self.metrics.nodeSize,indexSet)]
            }
            indexSet.addIndex(indexPath.item)
            return [.Normal(self.metrics.nodeSize,indexSet)]
        })
    }
	// we need to cache all the layout information (in the SectionDescription struct is in order to get the content size for the scroll view.
	// we use the offset and size information of the section description to calculate the content size.
	override func collectionViewContentSize() -> CGSize
    {
		if let _ = self.dataController, sectionDescriptions = self.sectionDescriptions
        {
			var width: CGFloat = 0.0
			if let lastSection = sectionDescriptions.last
            {
			    width = lastSection.maxX + metrics.sectionMargin
			}
            
			let height = sectionDescriptions.map { $0.size.height }
                .reduce(0.0, combine: max)

			return CGSize(width: width, height: height)
		}
		return super.collectionViewContentSize()
	}

    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        return indexPathsForItemsInRect(rect)
            // get the indexPaths
            .flatMap
            { itemIndexPath -> [UICollectionViewLayoutAttributes] in
                return [itemIndexPath].flatMap { self.layoutAttributesForItemAtIndexPath($0) }
                +
                    self.indexPathsForChildrenOfItemAtIndexPath(itemIndexPath)
                    .flatMap { self.layoutAttributesForSupplementaryViewOfKind(SchematicLayout.connectorViewKind, atIndexPath: $0) }
        }
    }

	override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes?
    {
		let attributes = SchematicLayoutAttributes(forCellWithIndexPath: indexPath)
        guard let frame = sectionDescriptions?[indexPath.section].frameForItemAtIndex(indexPath.item) else
        {
            return attributes
        }
        
        attributes.frame = frame
		return attributes
	}
    
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes?
    {
            let attributes = SchematicLayoutAttributes(forSupplementaryViewOfKind: elementKind, withIndexPath: indexPath)
            if let sectionDescriptions = self.sectionDescriptions
            {
                let childSectionDescription = sectionDescriptions[indexPath.section]
                let childFrame = childSectionDescription.frameForItemAtIndex(indexPath.item)
                for parentIndex in childSectionDescription.items[indexPath.item].parents
                {
                    let parentIndexPath = NSIndexPath(row: parentIndex, section: indexPath.section - 1)
                    let parentFrame = sectionDescriptions[parentIndexPath.section].frameForItemAtIndex(parentIndexPath.item)
                    let y = min(parentFrame.midY, childFrame.midY)
                    attributes.frame = CGRect(x: parentFrame.maxX, y: y, width: abs(childFrame.minX - parentFrame.maxX), height: abs(childFrame.midY - parentFrame.midY))
                    attributes.connectorLineStartTop = parentFrame.midY > childFrame.midY
                }
            }
            return attributes
    }
}


