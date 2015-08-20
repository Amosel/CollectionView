import Foundation

extension Array {
	func optionalElementAtIndex(index:Int) -> Array.Generator.Element? {
		if self.count > index {
			return self[index]
		}
		return nil
	}
}

extension SequenceType {
    func mapWithIndex<T>(transform:(Int,Self.Generator.Element)->T) -> [T] {
        var mutable = [T]()
        for (index, element) in self.enumerate() {
            let new = transform(index, element)
            mutable.append(new)
        }
        return mutable
    }
    func flatMapWithIndex<T>(transform:(Int,Self.Generator.Element)->[T]) -> [T] {
        var mutable = [T]()
        for (index, element) in self.enumerate() {
            let new = transform(index, element)
            mutable += new
        }
        return mutable
    }
}


extension CollectionType where Self.Generator.Element : Equatable {
    
    func any (test:(Self.Generator.Element)->Bool ) -> Bool {
        for element in self {
            if test(element) { return true }
        }
        return false
    }

    func count(test:(Self.Generator.Element)->Bool ) -> Int {
        return reduce(0) { if test($1) { return $0 + 1 } else { return $0 } }
    }

    func countToken <T:Hashable> (test:(Self.Generator.Element)->T ) -> Int {
        return reduce([T]()) {(var sum, let item) in
            let token = test(item)
            if !sum.contains( token )
            {
                sum.append(token)
            }
            return sum
        }.count
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
            if var array = bundle[key] {
                array.append(element)
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
            if var array = bundle[key] {
                array.append(newElement)
            } else {
                bundle[key] = [newElement]
            }
            return bundle
        }
    }
    
    func groupBy<Key : Hashable, NewKey: Hashable,NewValue >(fn:(Element)->(Key,NewKey,NewValue)) -> [Key:[NewKey : NewValue]] {
        typealias Bundle = [Key:[NewKey : NewValue]]
        return reduce(Bundle()) { (var bundle, element) in
            let (key, newKey, newValue) = fn(element)
            if var dictionary = bundle[key] {
                dictionary[newKey] = newValue
            } else {
                bundle[key] = [newKey : newValue]
            }
            return bundle
        }
    }    
}

