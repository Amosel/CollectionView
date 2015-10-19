import UIKit

protocol CollectionViewItem : Equatable, Hashable {
    var indexPath : NSIndexPath { get }
    var layoutAttributes : UICollectionViewLayoutAttributes? { get }
    var supplementaryAttributesKind : String? { get }
}

protocol LayoutItemsDataSource {
    typealias Item
    var items:[Item] { get }
    var size : CGSize { get }
    func itemsForInRect(rect:CGRect) -> [Item]
    mutating func prepare()
}

final class MyCollectionViewLayout  <T:LayoutItemsDataSource where T.Item : CollectionViewItem> : UICollectionViewLayout {
    
    typealias DataSourceType = T
    
    var dataSource:DataSourceType
    
    init(dataSource:DataSourceType) {
        self.dataSource = dataSource
        super.init()
    }
    
    override func prepareLayout() {
        // here the data we are dealing with is static, so the section description is only populated once.
        // when the data controller sections change, the section description should change too.
        dataSource.prepare()
    }

    // we need to cache all the layout information (in the SectionDescription struct is in order to get the content size for the scroll view.
    // we use the offset and size information of the section description to calculate the content size.
    override func collectionViewContentSize() -> CGSize
    {
        return dataSource.size
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        return dataSource.itemsForInRect(rect).flatMap { $0.layoutAttributes }
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes?
    {
        return dataSource.items.filter({ (item) -> Bool in
            item.indexPath == indexPath
        }).flatMap({ (item) in
            item.layoutAttributes
        }).first
    }
    
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes?
    {
        return dataSource.items.filter({ (item) -> Bool in
            item.indexPath == indexPath && item.supplementaryAttributesKind == elementKind
        }).flatMap({ (item) in
            item.layoutAttributes
        }).first
    }
}


