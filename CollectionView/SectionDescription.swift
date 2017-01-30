import UIKit

enum Direction {
    case vertical
    case horizontal
}

protocol HasParents  {
    var parents: IndexSet { get }
}

protocol SectionDescriptionItemProtocol : HasSize, HasParents {
    init(itemSize:CGSize, parents:IndexSet)
}

struct SectionDescription <T> where T : SectionDescriptionItemProtocol {
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

    private var sizes : [CGSize] { return self.items.map { $0.size } }

    init(index: Int, offset: CGPoint = .zero, items: [Item] = [], direction: Direction = .horizontal, itemPadding: CGFloat = 40) {
        self.index = index
        self.offset = offset
        self.items = items
        self.itemPadding = itemPadding
        self.direction = direction
        recalculateSize()
    }

    mutating func recalculateSize() {

        func accumWidthMaxHeight(accum:CGSize, size:CGSize) -> CGSize {
            return CGSize(width: accum.width + size.width + self.itemPadding, height: max(size.height, accum.height))
        }
        func accumHeightMaxWidth(accum:CGSize, size:CGSize) -> CGSize {
            return CGSize(width: max(size.width, accum.width), height: accum.height + size.height + self.itemPadding)
        }

        size = sizes.reduce(CGSize.zero, direction == .vertical ? accumWidthMaxHeight : accumHeightMaxWidth)

        frame = CGRect(origin: offset, size: size)
    }
    
    func frameForItem(at index: Int) -> CGRect {

        let itemSize = sizes[index]
        let indexFloat = CGFloat(index)

        switch direction {
        case .horizontal:
            let previousNodeHeight = sizes[0..<index].map { $0.height }.reduce(0.0, +)
            let y = (itemPadding / 2.0) + previousNodeHeight + (indexFloat * itemPadding)
            let centeringXOffset = (size.width - itemSize.width) / 2.0
            let origin = CGPoint(x: offset.x + centeringXOffset, y: y)
            return CGRect(origin: origin, size: itemSize)
        case .vertical:
            let previousNodeWidth = sizes[0..<index].map { $0.width }.reduce(0.0, +)
            let x = (itemPadding / 2.0) + previousNodeWidth + (indexFloat * itemPadding)
            let centeringYOffset = (size.height - itemSize.height) / 2.0
            let origin = CGPoint(x:x, y: offset.y + centeringYOffset)
            return CGRect(origin: origin, size: itemSize)
        }
    }

    func contained(in rect:CGRect) -> Bool {
        return offset.x >= rect.minX && offset.x <= rect.maxX
    }

    func itemIndexes(in rect:CGRect) -> [Int] {
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

    func supplementaryIndexes(in rect:CGRect) -> [Int] {
        return []
    }
    
    func itemsInRect(_ rect:CGRect) -> [Item] {
        switch self.direction {
        case .horizontal:
            if offset.x >= rect.minX && offset.x <= rect.maxX {
                var accum: CGFloat = 0
                var indexFloat: CGFloat = -1
                return items.filter {
                    indexFloat += 1
                    let size = $0.size
                    accum += size.height
                    let x = offset.x + ((size.width - size.width) / 2.0)
                    let y = (itemPadding / 2.0) + accum + (indexFloat * itemPadding)
                    return rect.contains(CGRect(x: x, y: y, width: size.width, height: size.height))
                }
            }
        case .vertical:
            if offset.y >= rect.minY && offset.y <= rect.maxY {
                var accum: CGFloat = 0
                var indexFloat: CGFloat = -1
                return items.filter {
                    indexFloat += 1
                    let size = $0.size
                    accum += size.width
                    let y = offset.y + ((size.height - size.height) / 2.0)
                    let x = (itemPadding / 2.0) + accum + (indexFloat * itemPadding)
                    return rect.contains(CGRect(x: x, y: y, width: size.width, height: size.height))
                }
            }
        }
        return []
    }
}
