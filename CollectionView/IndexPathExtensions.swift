import Foundation

protocol IndexPath {
    var sectionIndex: Int { get}
    var rowIndex : Int { get }
    static func new(rowIndex:Int, sectionIndex: Int) -> IndexPath
}

extension NSIndexPath : IndexPath {
    
    var sectionIndex : Int {
        get {
            return indexAtPosition(0)
        }
    }
    
    var rowIndex:Int {
        get {
            return indexAtPosition(1)
        }
    }
    
    static func new(path:[Int]) -> NSIndexPath {
        let buffer = UnsafeMutablePointer<Int>.alloc(path.count)
        for (index,pathElement) in path.enumerate() {
            buffer[index] = pathElement
        }
        return NSIndexPath(indexes: buffer, length: path.count)
    }

    static func new(rowIndex: Int, sectionIndex: Int) -> IndexPath {
        return new([rowIndex, sectionIndex])
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
    
    convenience init(rowIndex: Int, sectionIndex: Int) {
        let path = [rowIndex, sectionIndex]
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

    func indexesInSection(section:Int) -> [Self.Generator.Element] {
        return self.filter { $0.sectionIndex == section }
    }
    func lastIndexPathInSection(section:Int) -> Self.Generator.Element {
        return indexesInSection(section).last ?? Self.Generator.Element.new(0, sectionIndex: section) as! Self.Generator.Element
    }
    func nextRowAtSection(section:Int) -> Int {
        return indexesInSection(section).last?.rowIndex ?? 0
    }
    func nextIndexPathInSection(section:Int) -> Self.Generator.Element {
        return Self.Generator.Element.new(0, sectionIndex: section) as! Self.Generator.Element
    }
}

