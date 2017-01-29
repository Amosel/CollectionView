import Foundation

struct IndexPathMap <T: Equatable> {

    typealias Elements = [IndexPath : T]
    
    var storage = Elements()

    init(createElements:() -> (Elements)) {
        storage = createElements()
    }

    func element(at indexPath: IndexPath) -> T? {
        guard let index = storage.index(forKey: indexPath) else {
            return nil
        }
        return storage[index].value
    }

    func indexPath(for object: T) -> IndexPath? {
        if let index = storage.index(where: { $0.value == object }) {
            return storage[index].key
        }
        return nil
    }

    func numberOfRows(in section:Int) -> Int {
        let items = storage.keys.filter({ $0.section == section })
        return items.count
    }

    var numberOfSections: Int { return Set( storage.keys.map { $0.section }).count }

    func nextIndexPathAtSection(_ section:Int) -> IndexPath {
        return storage.keys.nextIndexPathInSection(section)
    }
    
    var sections : [Int : [Int : T]] {
        return storage.group { ($0.0.section, $0.0.row, $0.1) }
    }
}
