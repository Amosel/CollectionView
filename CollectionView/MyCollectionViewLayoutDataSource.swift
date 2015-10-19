import UIKit

//extension LayoutMetrics {
//    var sectionMargin:CGFloat { get }
//    var nodeSize:CGSize { get }
//    var sectionPadding:CGFloat { get }
//    init()
//}
//
//struct ItemMetrics {
//}
//
//struct MySectionMetrics {
//    typealias ItemMetrics
//    var offset:CGFloat = 0
//    var itemPadding:CGFloat = 0
//    func itemMetricsAtIndex(sectionIndex:Int) -> ItemMetrics
//}
//
//struct MyLayoutMetrics : LayoutMetrics {
//    var sectionMargin:CGFloat = 12
//    var nodeSize = CGSizeMake(100, 100)
//    var sectionPadding:CGFloat = 30
//}
//
//extension LayoutMetrics {
//    func sectionMetricsAtIndex(sectionIndex:Int) -> MySectionMetrics {
//        let sectionIndexFloat = CGFloat(sectionIndex)
//        let offset = sectionMargin + (sectionIndexFloat * nodeSize.width) + (sectionIndexFloat * sectionPadding)
//        return MySectionMetrics(offset: offset, itemPadding: 0)
//    }
//}

//struct MySectionMetrics : SectionMetrics {
//        typealias ItemMetrics
//        var offset:CGFloat = 0
//        var itemPadding:CGFloat = 0
//
//    func sectionMetricsAtIndex(sectionIndex:Int) -> MySectionMetrics {
//        let sectionIndexFloat = CGFloat(sectionIndex)
//        let offset = sectionMargin + (sectionIndexFloat * nodeSize.width) + (sectionIndexFloat * sectionPadding)
//        return MySectionMetrics(offset: offset, itemPadding: 0)
//    }
//}
//size = self.items.reduce(CGSizeZero)
//    { accum, item in
//        let width = max(item.size.width, accum.width)
//        let height = accum.height + item.size.height + self.metrics.itemPadding
//        return CGSize(width: width, height: height)
//}

//struct MySection <T:CollectionViewItem, M:SectionLayout> {
//    typealias ItemType = T
//    typealias Layout = M
//    var layout:Layout {
//        didSet {
//            calculateSize()
//        }
//    }
//    var index:Int
//    var items:[ItemType]
//
//    init(index:Int, layout : Layout, items : [ItemType]) {
//        self.index = index
//        self.items = items
//        self.layout = layout
//        calculateSize()
//    }
//    
//    mutating func calculateSize() {
//        size = layout.size
//    }
//    var size = CGSizeZero
//}
//
//struct MyCollectionViewLayoutDataSource <T:CollectionViewItem, L: CollectionLayout> : LayoutItemsDataSource {
//    
//    typealias SectionType = MySection<T,L.SectionLayout>
//    typealias Layout = L,
//    
//    var metrics:Layout = Layout()
//    let createItems:() -> [SectionType.Item]
//
//    mutating func prepare() {
//        sections = createItems().groupBy{ $0.indexPath.section }
//            .map {(sectionIndex,items) in
//                return MySection(index: sectionIndex,  layout: layout.sectionLayoutAtIndex(sectionIndex), items: items)
//        }
//    }
//
//    var sections:[SectionType] = [SectionType]() {
//        didSet {
//            func calculateSize() ->CGSize {
//                var width: CGFloat = 0.0
//                if let lastSection = sections.last
//                {
//                    width = lastSection.layout.maxX + layout.sectionMargin
//                }
//                
//                let height = sections.map { $0.size.height }
//                    .reduce(0.0, combine: max)
//                
//                return CGSize(width: width, height: height)
//            }
//            size = calculateSize()
//        }
//    }
//
//    var size = CGSizeZero
//
//    var items:[SectionType.Item] {
//        get {
//            return self.sections.flatMap { $0.items }
//        }
//    }
//    
//    func sectionsInRect(rect:CGRect) -> [SectionType]
//    {
//        return sections.filter { $0.metrics.offset >= rect.minX && $0.metrics.offset <= rect.maxX }
//    }
//
//    func indexPathsInRect(rect:CGRect) -> [NSIndexPath] {
//        return itemsForInRect(rect).map { $0.indexPath }
//    }
//    
//    func itemsForInRect(rect:CGRect) -> [SectionType.Item] {
//        return sectionsInRect(rect).flatMap { $0.itemsInRect(rect) }
//    }
//
//    func layoutAttributesForItem(items:[SectionType.Item]) -> [UICollectionViewLayoutAttributes] {
//        return []
//    }
//}
