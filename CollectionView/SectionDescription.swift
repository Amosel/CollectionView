import UIKit

enum Direction {
    case vertical
    case horizontal
}

struct SectionDescription <T> where T : HasSize{
    typealias Item = T

    let index: Int
    let direction : Direction
    let offset: CGPoint
    let itemPadding: CGFloat
    var size: CGSize = .zero
    var frame : CGRect = .zero
    var items: [Item] {
        didSet {
            recalculateSize()
        }
    }
    
    init(index:Int, offset: CGPoint = .zero, items: [Item] = [], direction: Direction = .horizontal, itemPadding: CGFloat = 40) {
        self.index = index
        self.offset = offset
        self.items = items
        self.itemPadding = itemPadding
        self.direction = direction
        recalculateSize()
    }

    mutating func recalculateSize() {
        size = items
            .map{ $0.size }
            .reduce(CGSize.zero) { accum, size in
                return CGSize(width: max(size.width, accum.width), height: accum.height + size.height + self.itemPadding)
        }
        frame = CGRect(origin: offset, size: size)
    }
    
    func frameForItem(at index: Int) -> CGRect {
        switch direction {
        case .horizontal:
            let indexFloat = CGFloat(index)
            let previousNodeSizes = items.map { $0.size }[0..<index].reduce(0.0) { accum, size in accum + size.height }
            let y = (itemPadding / 2.0) + previousNodeSizes + (indexFloat * itemPadding)
            let thisItem = items[index]
            let centeringXOffset = (size.width - thisItem.size.width) / 2.0
            let origin = CGPoint(x: offset.x + centeringXOffset, y: y)
            return CGRect(origin: origin, size: thisItem.size)
        case .vertical:
            let indexFloat = CGFloat(index)
            let previousNodeSizes = items.map { $0.size }[0..<index].reduce(0.0) { accum, size in accum + size.width }
            let x = (itemPadding / 2.0) + previousNodeSizes + (indexFloat * itemPadding)
            let thisItem = items[index]
            let centeringYOffset = (size.height - thisItem.size.height) / 2.0
            let origin = CGPoint(x:x, y: offset.y + centeringYOffset)
            return CGRect(origin: origin, size: thisItem.size)
        }
    }
    
    func itemIndexesInRect(_ rect:CGRect) -> [Int] {
        switch direction {
        case .horizontal:
            if offset.x >= rect.minX && offset.x <= rect.maxX {
                var accum: CGFloat = 0
                return (0 ..< items.count).filter {
                    let size = items[$0].size
                    accum += size.height
                    let x = offset.x + ((size.width - size.width) / 2.0)
                    let y = (itemPadding / 2.0) + accum + (CGFloat($0) * itemPadding)
                    return rect.contains(CGRect(x: x, y: y, width: size.width, height: size.height))
                }
            }
        case .vertical:
            if offset.y >= rect.minY && offset.y <= rect.maxY {
                var accum: CGFloat = 0
                return (0 ..< items.count).filter {
                    let size = items[$0].size
                    accum += size.width
                    let y = offset.y + ((size.height - size.height) / 2.0)
                    let x = (itemPadding / 2.0) + accum + (CGFloat($0) * itemPadding)
                    return rect.contains(CGRect(x: x, y: y, width: size.width, height: size.height))
                }
            }
        }
        return []
    }
    
    func itemsInRect(_ rect:CGRect) -> [Item] {
        if offset.x >= rect.minX && offset.x <= rect.maxX {
            var accumHeight:CGFloat = 0
            var indexFloat:CGFloat = -1
            return items.filter {
                indexFloat += 1
                let size = $0.size
                accumHeight += size.height
                let x = offset.x + ((size.width - size.width) / 2.0)
                let y = (itemPadding / 2.0) + accumHeight + (indexFloat * itemPadding)
                return rect.contains(CGRect(x: x, y: y, width: size.width, height: size.height))
            }
        }
        return []
    }
}
