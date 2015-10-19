import UIKit

protocol HasFrame {
    var frame:CGRect { get }
    var insets:UIEdgeInsets { get }
}

extension HasFrame {
    var origin:CGPoint { return frame.origin }
    var bounds: CGRect { return UIEdgeInsetsInsetRect(frame, insets) }
    var maxX:CGFloat { return CGRectGetMaxX(frame) }
    var maxY:CGFloat { return CGRectGetMaxY(frame) }
    var minX:CGFloat { return CGRectGetMinX(frame) }
    var minY:CGFloat { return CGRectGetMinY(frame) }
}

protocol NodeLayout : HasFrame {
    typealias ChildLayout
    func childLayoutAtIndex(sectionIndex:Int) -> ChildLayout
}

//func frameForItemAtIndex(index: Int) -> CGRect {
//    let indexFloat = CGFloat(index)
//    let previousNodeSizes = items[0..<index].reduce(0.0) { accum, item in accum + item.size.height }
//    let y = (metrics.itemPadding / 2.0) + previousNodeSizes + (indexFloat * metrics.itemPadding)
//    let thisItem = items[index]
//    let centeringXOffset = (size.width - thisItem.size.width) / 2.0
//    let origin = CGPoint(x: metrics.offset + centeringXOffset, y: y)
//    return CGRect(origin: origin, size: thisItem.size)
//}
//
//func itemIndexesInRect(rect:CGRect) -> [Int] {
//    if metrics.offset >= rect.minX && metrics.offset <= rect.maxX
//    {
//        var accumHeight:CGFloat = 0
//        return Range<Int>(start: 0, end: items.count).filter {
//            let size = items[$0].size
//            accumHeight += size.height
//            let x = metrics.offset + ((size.width - size.width) / 2.0)
//            let y = (metrics.itemPadding / 2.0) + accumHeight + (CGFloat($0) * metrics.itemPadding)
//            return rect.contains(CGRectMake(x, y, size.width, size.height))
//        }
//    }
//    return []
//}
//func itemsInRect(rect:CGRect) -> [Item]{
//    if metrics.offset >= rect.minX && metrics.offset <= rect.maxX
//    {
//        var accumHeight:CGFloat = 0
//        var indexFloat:CGFloat = -1
//        return items.filter {
//            indexFloat++
//            let size = $0.size
//            accumHeight += size.height
//            let x = metrics.offset + ((size.width - size.width) / 2.0)
//            let y = (metrics.itemPadding / 2.0) + accumHeight + (indexFloat * metrics.itemPadding)
//            return rect.contains(CGRectMake(x, y, size.width, size.height))
//        }
//    }
//    return []
//}
