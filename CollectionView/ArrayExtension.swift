import Foundation

extension Array {
	func optionalElementAtIndex(index:Int) -> Array.Generator.Element? {
		if self.count > index {
			return self[index]
		}
		return nil
	}
}

extension Array {
    func any (test:(Element)->Bool ) -> Bool {
        for element in self {
            if test(element) { return true }
        }
        return false
    }
}


extension Dictionary {
    func any (test:(Value)->Bool ) -> Key? {
        for (key,value) in self {
            if test(value) { return key }
        }
        return nil
    }
}
