import UIKit

protocol LayoutMetrics {
    var sectionMargin:CGFloat { get }
    var nodeSize:CGSize { get }
    var sectionPadding:CGFloat { get }
    init()
}

protocol Sizable {
    var size : CGSize { get }
}

protocol IndexPathable {
    var indexPath : NSIndexPath { get }
}

struct SupplementaryItemDescripton {
    let kind:String
}

protocol CollectionViewItem : Sizable, IndexPathable, Equatable, Hashable {
    var supplementaryItemDescription:SupplementaryItemDescripton? { get }
}

protocol LayoutItemsProvider : Sizable {
    typealias Item
    var items:[Item] { get }
    func itemsForInRect(rect:CGRect) -> [Item]
    func layoutAttributesForItem(items:[Item]) -> [UICollectionViewLayoutAttributes]
}

//
class MyCollectionViewLayout <M:LayoutMetrics, T:LayoutItemsProvider where T.Item : CollectionViewItem> : UICollectionViewLayout {
    typealias Metrics = M
    typealias ItemProviderType = T
    override init() {
        super.init()
    }
    
    var itemProvider:ItemProviderType? {
        didSet {
            self.invalidateLayout()
        }
    }
    var metrics:Metrics = Metrics()
        {
        didSet {
            self.invalidateLayout()
        }
    }
    
    override func prepareLayout() {
        // here the data we are dealing with is static, so the section description is only populated once.
        // when the data controller sections change, the section description should change too.
    }

    // we need to cache all the layout information (in the SectionDescription struct is in order to get the content size for the scroll view.
    // we use the offset and size information of the section description to calculate the content size.
    override func collectionViewContentSize() -> CGSize
    {
        return itemProvider?.size ?? super.collectionViewContentSize()
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        return itemProvider?.itemsForInRect(rect).flatMap {
            if let supplementary = $0.supplementaryItemDescription {
                return layoutAttributesForSupplementaryViewOfKind(supplementary.kind, atIndexPath: $0.indexPath)
            } else {
                return layoutAttributesForItemAtIndexPath($0.indexPath)
            }
        }
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes?
    {
        guard let itemProvider = itemProvider, item = itemProvider.items.filter({ (item) -> Bool in
            return item.indexPath == indexPath && item.supplementaryItemDescription == nil
        }).first else {
            return nil
        }
        return itemProvider.layoutAttributesForItem([item]).first
    }
    
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes?
    {
        guard let itemProvider = itemProvider, item = itemProvider.items.filter({ (item) -> Bool in
            return item.indexPath == indexPath && item.supplementaryItemDescription?.kind == elementKind
        }).first else {
            return nil
        }
        return itemProvider.layoutAttributesForItem([item]).first

    }
}


