import UIKit

protocol CollectionViewLayoutMetrics {
    var sectionMargin: CGFloat { get }
    var itemSize: CGSize { get }
    var sectionPadding: CGFloat { get }
    init()
}

protocol HasSize {
    var size: CGSize { get }
}

protocol LayoutDataControllerProtocol {
    associatedtype Element : Hashable, Equatable
    func indexPath(for element: Element) -> IndexPath?
    func indexPathForParent(for element:Element) -> IndexPath?
    var sections : [[Element]] { get }
}

extension LayoutDataControllerProtocol {

    func createSections(metrics:CollectionViewLayoutMetrics, direction:Direction) -> [ SectionDescription<SchematicItem> ] {
        return sections.enumerated().map { sectionIndex, nodes in
            let sectionIndexFloat = CGFloat(sectionIndex)
            let offset : CGPoint
            switch direction {
            case .horizontal:
                offset = CGPoint(
                    x: metrics.sectionMargin + (sectionIndexFloat * metrics.itemSize.width) + (sectionIndexFloat * metrics.sectionPadding),
                    y: 0
                )
            case .vertical:
                offset = CGPoint(
                    x: 0,
                    y: metrics.sectionMargin + (sectionIndexFloat * metrics.itemSize.height) + (sectionIndexFloat * metrics.sectionPadding)
                )
            }
            let items = nodes
                .enumerated()
                .flatMap { (sectionIndex, node) -> [SchematicItem] in
                    var indexSet = IndexSet()
                    guard let parentIndexPath = indexPathForParent(for: node) else {
                        return [.normal(metrics.itemSize, indexSet)]
                    }
                    indexSet.update(with: parentIndexPath.item)
                    return [.normal(metrics.itemSize, indexSet)]
            }
            return SectionDescription(index: sectionIndex, offset: offset, items: items, direction: direction)
        }
    }
}

class CollectionViewLayout <M: CollectionViewLayoutMetrics, C: LayoutDataControllerProtocol> : UICollectionViewLayout {

    typealias SectionProtocol = SectionDescription<SchematicItem>
    typealias Metrics = M
    
    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var direction: Direction = .horizontal
	var sectionDescriptions: [SectionProtocol]?
    var dataController : C?

    var metrics: Metrics = Metrics()
    {
        didSet {
            self.invalidateLayout()
        }
    }

    override func prepare() {
        // here the data we are dealing with is static, so the section description is only populated once.
        // when the data controller sections change, the section description should change too.
        self.sectionDescriptions = dataController?.createSections(metrics: self.metrics, direction: direction)
    }
    
	// we need to cache all the layout information (in the SectionDescription struct is in order to get the content size for the scroll view.
	// we use the offset and size information of the section description to calculate the content size.
	override var collectionViewContentSize : CGSize {
		if let _ = self.dataController, let sectionDescriptions = self.sectionDescriptions {
            switch self.direction {
            case .horizontal:
                var width: CGFloat = 0.0
                if let lastSection = sectionDescriptions.last {
                    width = lastSection.frame.maxX + metrics.sectionMargin
                }
                let height = sectionDescriptions.map { $0.size.height }.reduce(0.0,max)
                return CGSize(width: width, height: height)
            case .vertical:
                var height: CGFloat = 0.0
                if let lastSection = sectionDescriptions.last {
                    height = lastSection.frame.maxY + metrics.sectionMargin
                }
                let width = sectionDescriptions.map { $0.size.width }.reduce(0.0, max)
                return CGSize(width: width, height: height)
            }
		}
		return super.collectionViewContentSize
	}

    func sectionsInRect(_ rect:CGRect) -> [SectionProtocol] {
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
            return self.sectionDescriptions?
                .filter { $0.contained(in: rect) }
                .flatMap({ (section) -> [UICollectionViewLayoutAttributes] in
                    section.itemIndexes(in: rect)
                        .flatMap { itemIndex -> [UICollectionViewLayoutAttributes] in
                            let sectionIndex = section.index
                            let indexPath = IndexPath(item: itemIndex, section: sectionIndex)

                            var attribtes = [self.layoutAttributesForItem(at: indexPath as IndexPath)!]

                            let nextSectionIndex = sectionIndex + 1
                            if let nextSection = sectionDescriptions!.optional(at: nextSectionIndex) {
                                let children = nextSection.items
                                    .enumerated()
                                    .filter { _, child in child.parents.contains(itemIndex) }
                                    .map { IndexPath(item: $0.offset, section: nextSectionIndex) }
                                    .flatMap { self.layoutAttributesForSupplementaryView(ofKind: SchematicLayout.connectorViewKind, at: $0) }

                                attribtes.append(contentsOf: children)
                            }
                            return attribtes
                    }
                })
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
            if let sectionDescriptions = self.sectionDescriptions {
                let childSectionDescription = sectionDescriptions[indexPath.section]
                let childFrame = childSectionDescription.frameForItem(at: indexPath.item)
                for parentIndex in childSectionDescription.items[indexPath.item].parents {
                    let parentIndexPath = IndexPath(item: parentIndex, section: indexPath.section - 1)
                    let parentFrame = sectionDescriptions[parentIndexPath.section].frameForItem(at: parentIndexPath.item)

                    switch direction {
                    case .horizontal:
                        let y = min(parentFrame.midY, childFrame.midY)
                        let frame = CGRect(
                            x: parentFrame.maxX,
                            y: y,
                            width: abs(childFrame.minX - parentFrame.maxX),
                            height: abs(childFrame.midY - parentFrame.midY)
                        )
                        attributes.frame = frame
                        attributes.connectorLineStartTop = parentFrame.midY > childFrame.midY
                    case .vertical:
                        let x = min(parentFrame.midX, childFrame.midX)
                        let frame = CGRect(
                            x: x,
                            y: parentFrame.maxY,
                            width: abs(childFrame.midX - parentFrame.midX),
                            height: abs(childFrame.minY - parentFrame.maxY)
                        )
                        attributes.frame = frame
                        attributes.connectorLineStartTop = parentFrame.midY > childFrame.midY
                    }
                }
            }
            return attributes
    }
}


