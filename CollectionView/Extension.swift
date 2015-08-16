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
    func count(test:(Element)->Bool ) -> Int {
        return reduce(0) { if test($1) { return $0 + 1 } else { return $0 } }
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

extension CollectionType {
    typealias Element = Generator.Element
    
    func groupBy<Key : Hashable >(fn:(Element)->(Key)) -> [Key:[Element]] {
        typealias Bundle = [Key:[Element]]
        return reduce(Bundle()) { (var bundle, element) in
            let key = fn(element)
            if bundle[key] != nil {
                bundle[key]!.append(element)
            } else {
                bundle[key] = [element]
            }
            return bundle
        }
        
    }
    
    func groupBy<Key : Hashable, NewElement >(fn:(Element)->(Key,NewElement)) -> [Key:[NewElement]] {
        typealias Bundle = [Key:[NewElement]]
        return reduce(Bundle()) { (var bundle, element) in
            let (key, newElement) = fn(element)
            if bundle[key] != nil {
                bundle[key]!.append(newElement)
            } else {
                bundle[key] = [newElement]
            }
            return bundle
        }
    }
}

