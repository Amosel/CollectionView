import UIKit

struct AmosLayoutItemsProvider : LayoutItemsProvider {
    typealias Item = MyCollectionViewItem
    
    var size : CGSize {
        get {
            return CGSizeZero
        }
    }
    
    var items:[Item] {
        get {
            return []
        }
    }
    func itemsForInRect(rect:CGRect) -> [Item] {
        return []
    }
    func layoutAttributesForItem(items:[Item]) -> [UICollectionViewLayoutAttributes] {
        return []
    }
}