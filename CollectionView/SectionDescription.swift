import UIKit

struct SectionDescription {
	typealias Item = (size: CGSize, parents: NSIndexSet)
	var offset: CGFloat {
		didSet {
			self.recalculateSize()
		}
	}
	var size: CGSize = CGSizeZero
	var itemPadding: CGFloat = 40
	var items: [Item] {
		didSet {
			self.recalculateSize()
		}
	}
	init(offset: CGFloat = 0.0, items: [Item] = [Item]()) {
		self.offset = offset
		self.items = items
		self.recalculateSize()
	}
	var maxX: CGFloat { return offset + size.width }

	mutating func recalculateSize() {
		self.size = self.items.reduce(CGSizeZero) { accum, item in
			return CGSize(width: max(item.size.width, accum.width), height: accum.height + item.size.height + self.itemPadding)
		}
	}
	func frameForItemAtIndex(index: Int) -> CGRect {
		let indexFloat = CGFloat(index)
		let previousNodeSizes = self.items[0..<index].reduce(0.0) { accum, item in accum + item.size.height }
		let y = (self.itemPadding / 2.0) + previousNodeSizes + (indexFloat * self.itemPadding)
		let thisItem = self.items[index]
		let centeringXOffset = (self.size.width - thisItem.size.width) / 2.0
		let origin = CGPoint(x: self.offset + centeringXOffset, y: y)
		return CGRect(origin: origin, size: thisItem.size)
	}
}