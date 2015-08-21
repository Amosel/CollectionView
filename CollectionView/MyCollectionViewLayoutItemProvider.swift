import UIKit

struct MySection <T:CollectionViewItem> {
    typealias Item = T
    
    var offset:CGFloat
    var size:CGSize
    var itemPadding:CGFloat

    var index:Int
    
    var items = [Item]()
    
    
    func itemIndexesInRect(rect:CGRect) -> [Int]{
        if offset >= rect.minX && offset <= rect.maxX
        {
            var accumHeight:CGFloat = 0
            return Range<Int>(start: 0, end: items.count).filter {
                let size = items[$0].size
                accumHeight += size.height
                let x = offset + ((size.width - size.width) / 2.0)
                let y = (itemPadding / 2.0) + accumHeight + (CGFloat($0) * itemPadding)
                return rect.contains(CGRectMake(x, y, size.width, size.height))
            }
        }
        return []
    }
    func itemsInRect(rect:CGRect) -> [Item]{
        if offset >= rect.minX && offset <= rect.maxX
        {
            var accumHeight:CGFloat = 0
            var indexFloat:CGFloat = -1
            return items.filter {
                indexFloat++
                let size = $0.size
                accumHeight += size.height
                let x = offset + ((size.width - size.width) / 2.0)
                let y = (itemPadding / 2.0) + accumHeight + (indexFloat * itemPadding)
                return rect.contains(CGRectMake(x, y, size.width, size.height))
            }
        }
        return []
    }
}

struct MyCollectionViewLayoutItemProvider <T:CollectionViewItem> : LayoutItemsProvider {
    typealias SectionType = MySection<T>
    var size = CGSizeZero
    
    var sections:[SectionType] = [SectionType]() {
        didSet {
            
        }
    }

    var items:[SectionType.Item] {
        get {
            return self.sections.flatMap { $0.items }
        }
    }
    
    func sectionsInRect(rect:CGRect) -> [SectionType]
    {
        return sections.filter { $0.offset >= rect.minX && $0.offset <= rect.maxX }
    }

    func indexPathsInRect(rect:CGRect) -> [NSIndexPath] {
        return itemsForInRect(rect).map { $0.indexPath }
    }
    
    func itemsForInRect(rect:CGRect) -> [SectionType.Item] {
        return sectionsInRect(rect).flatMap { $0.itemsInRect(rect) }
    }

    func layoutAttributesForItem(items:[SectionType.Item]) -> [UICollectionViewLayoutAttributes] {
        return []
    }
}
