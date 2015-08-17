import Foundation

struct IndexPathMap <T: Equatable> {
    typealias Elements = [NSIndexPath:T]
    
    var storage = Elements()
    
    init(createElements:()->(Elements)) {
        storage = createElements()
    }
    func nodeAtIndexPath(indexPath: NSIndexPath) -> T? {
        return storage[indexPath]
    }
    func indexPathForObject(object: T) -> NSIndexPath? {
        return storage.any { $0 == object}
    }
    func numberOfRowsInSection(section:Int) -> Int {
        return storage.keys.count { $0.section == section }
    }
    var numberOfSections:Int {
        get {
            return storage.keys.array.countToken { $0.section }
        }
    }
    func nextIndexPathAtSection(section:Int) -> NSIndexPath {
        return NSIndexPath(row: storage.keys.nextRowAtSection(section), section: section)
    }
    var sections : [Int : [Int : T]] {
        return storage.groupBy { ($0.0.section, $0.0.row, $0.1) }
    }
}
