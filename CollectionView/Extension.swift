import Foundation

extension Sequence where Self.Iterator.Element == IndexPath {

    func nextItemIndexAtSection(_ section: Int) -> Int {
        return filter { section == $0.section }
            .map { $0.item + 1}
            .max() ?? 0
    }

    func nextIndexPathInSection(_ section:Int) -> Iterator.Element {
        return IndexPath(item: nextItemIndexAtSection(section), section: section)
    }
}

extension RandomAccessCollection where Index == Int {

    func optional(at index: Int) -> (Index, Iterator.Element)? {
        guard (startIndex..<endIndex).contains(index) else {
            return nil
        }
        return (index, self[index])
    }
}

extension Sequence {
    func mapWithIndex<T>(_ transform:(Int, Self.Iterator.Element) -> T) -> [T] {
        var mutable = [T]()
        for (index, element) in self.enumerated() {
            let new = transform(index, element)
            mutable.append(new)
        }
        return mutable
    }
    func flatMapWithIndex<T>(_ transform:(Int, Self.Iterator.Element) -> [T]) -> [T] {
        var mutable = [T]()
        for (index, element) in self.enumerated() {
            let new = transform(index, element)
            mutable += new
        }
        return mutable
    }
}

extension Collection {
    typealias Element = Iterator.Element
    
    func group<Key : Hashable >(with fn: (Element) -> (Key) ) -> [Key : [Element] ] {

        typealias Bundle = [ Key: [Element] ]

        var mutalbe = Bundle()

        forEach {
            let key = fn($0)
            if var array = mutalbe[key] {
                array.append($0)
            } else {
                mutalbe[key] = [$0]
            }
        }
        return mutalbe
    }
    
    func group <Key : Hashable, NewElement > (with fn: (Element) -> (Key, NewElement) ) -> [Key : [NewElement] ] {

        typealias Bundle = [ Key : [NewElement]]

        var mutalbe = Bundle()

        forEach {
            let (key, new) = fn($0)
            if var array = mutalbe[key] {
                array.append(new)
            } else {
                mutalbe[key] = [new]
            }
        }
        return mutalbe
    }
    
    func group<Key : Hashable, NewKey: Hashable, NewValue >(with fn:(Element) -> (Key, NewKey, NewValue)) -> [Key: [NewKey : NewValue] ] {

        typealias Bundle = [Key : [NewKey : NewValue]]

        var mutalbe = Bundle()

        forEach {
            let (key, newKey, newValue) = fn($0)
            if var dictionary = mutalbe[key] {
                dictionary[newKey] = newValue
            } else {
                mutalbe[key] = [newKey : newValue]
            }
        }
        return mutalbe
    }
}

