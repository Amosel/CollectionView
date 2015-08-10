import Foundation

extension Array {
	func optionalElementAtIndex(index:Int) -> Array.Generator.Element? {
		if self.count > index {
			return self[index]
		}
		return nil
	}
}
