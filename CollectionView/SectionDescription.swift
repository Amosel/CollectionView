import UIKit

protocol HasSize {
    var size:CGSize { get }
}

struct SectionDescription <T:HasSize> {
    typealias Item = T
    let index: Int
    let offset: CGFloat
    var size: CGSize = CGSizeZero
    var itemPadding: CGFloat = 40
    var items: [Item] {
        didSet {
            recalculateSize()
        }
    }
    
    init(index:Int, offset: CGFloat = 0.0, items: [Item] = [Item]()) {
        self.index = index
        self.offset = offset
        self.items = items
        self.size = self.items.reduce(CGSizeZero) { accum, item in
            return CGSize(width: max(item.size.width, accum.width), height: accum.height + item.size.height + self.itemPadding)
        }
    }
    
    var maxX: CGFloat { return offset + size.width }
    
    mutating func recalculateSize() {
        size = items.reduce(CGSizeZero) {
            accum, item in
            return CGSize(width: max(item.size.width, accum.width), height: accum.height + item.size.height + itemPadding)
        }
    }
    
    func frameForItemAtIndex(index: Int) -> CGRect {
        let indexFloat = CGFloat(index)
        let previousNodeSizes = items[0..<index].reduce(0.0) { accum, item in accum + item.size.height }
        let y = (itemPadding / 2.0) + previousNodeSizes + (indexFloat * itemPadding)
        let thisItem = items[index]
        let centeringXOffset = (size.width - thisItem.size.width) / 2.0
        let origin = CGPoint(x: offset + centeringXOffset, y: y)
        return CGRect(origin: origin, size: thisItem.size)
    }
    
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