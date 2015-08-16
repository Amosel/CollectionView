import Foundation

protocol IndexPath {
    var section: Int { get}
    var row : Int { get }
    static func new(row:Int, section: Int) -> IndexPath
}

extension NSIndexPath : IndexPath {
    
    static func new(path:[Int]) -> NSIndexPath {
        let buffer = UnsafeMutablePointer<Int>.alloc(path.count)
        for (index,pathElement) in path.enumerate() {
            buffer[index] = pathElement
        }
        return NSIndexPath(indexes: buffer, length: path.count)
    }

    static func new(row: Int, section: Int) -> IndexPath {
        return new([section, row])
    }
}

extension NSIndexPath {
    
    convenience init(path:[Int]) {
        let buffer = UnsafeMutablePointer<Int>.alloc(path.count)
        for (index,pathElement) in path.enumerate() {
            buffer[index] = pathElement
        }
        self.init(indexes: buffer, length: path.count)
    }
    
    convenience init(row: Int, section: Int) {
        let path = [section, row]
        let buffer = UnsafeMutablePointer<Int>.alloc(path.count)
        for (index,pathElement) in path.enumerate() {
            buffer[index] = pathElement
        }
        self.init(indexes: buffer, length: path.count)
    }

    public subscript (subrange: Range<Int>) -> NSIndexPath? {
        
        guard subrange.startIndex >= 0 else {
            return nil
        }
        
        let newLength = subrange.endIndex + 1 - subrange.startIndex
        guard newLength > 0 else {
            return nil
        }
        
        guard subrange.endIndex < length else {
            return nil
        }
        
        let indexes = indexesForRange(NSRange(location: subrange.startIndex, length: newLength))
        return NSIndexPath(indexes:indexes, length:newLength)
    }
    
    private func indexesForRange(range: NSRange) -> [Int] {
        var indexPointer: UnsafeMutablePointer<Int> = UnsafeMutablePointer.alloc(range.length)
        getIndexes(indexPointer, range: range)
        
        var indexes: [Int] = []
        for var i = 0; i < range.length; i++ {
            indexes.append(indexPointer[i])
        }
        
        return indexes
    }
}

extension SequenceType where Self.Generator.Element : IndexPath {

    func indexPathsInSection(section:Int) -> [Self.Generator.Element] {
        let indexPaths = self.filter {
            $0.section == section
        }
        return indexPaths
    }
    func lastIndexPathInSection(section:Int) -> Self.Generator.Element {
        return indexPathsInSection(section)
            .last ?? Self.Generator.Element.new(0, section: section) as! Self.Generator.Element
    }
    func nextRowAtSection(section:Int) -> Int {
        return self.filter { section == $0.section }.reduce(Int(0)) { max($0, $1.row + 1) }
    }
    func nextIndexPathInSection(section:Int) -> Self.Generator.Element {
        let nextRow = nextRowAtSection(section)
        return Self.Generator.Element.new(nextRow, section: section) as! Self.Generator.Element
    }
}

