import UIKit

// 
class CollectionViewLayout : UICollectionViewLayout {
	var sectionDescriptions:[SectionDescription]?
	var dataController : SchematicDataController?
	var sectionMargin:CGFloat = 12
	var nodeSize = CGSizeMake(100, 100)
	var sectionPadding:CGFloat = 30

	// here the data we are dealing with is static, so the section description is only populated once.
	// when the data controller sections change, the section description should change too.
	override func prepareLayout() {
		if self.sectionDescriptions == nil {
			var mutable = [SectionDescription]()
			if let dataController = self.dataController {
				for (sectionIndex, nodes) in dataController.sections.enumerate() {
					let sectionIndexFloat = CGFloat(sectionIndex)
					let offset = sectionMargin + (sectionIndexFloat * self.nodeSize.width) + (sectionIndexFloat * self.sectionPadding)
					let sectionInfo = SectionDescription(offset: offset, items: nodes.map { node in
						let indexSet = NSMutableIndexSet()
						if sectionIndex > 0
						{
							if let parent = node.parent, indexPath = dataController.indexPathForNode(parent) where indexPath.section == sectionIndex - 1
							{
								indexSet.addIndex(indexPath.item)
							}
						}
      					return (size: self.nodeSize, parents: indexSet)
					})
					mutable.append(sectionInfo)
    			}
			}
			sectionDescriptions = mutable
		}
	}
	// we need to cache all the layout information (in the SectionDescription struct is in order to get the content size for the scroll view.
	// we use the offset and size information of the section description to calculate the content size.
	override func collectionViewContentSize() -> CGSize {
		if let _ = self.dataController, sectionDescriptions = self.sectionDescriptions {
			var width: CGFloat = 0.0
			if let lastSection = sectionDescriptions.last {
			    width = lastSection.maxX + self.sectionMargin
			}
			let height = sectionDescriptions.map{ $0.size.height }.reduce(0.0,combine: max)
			return CGSize(width: width, height: height)
		}
		return super.collectionViewContentSize()
	}

	override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
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

