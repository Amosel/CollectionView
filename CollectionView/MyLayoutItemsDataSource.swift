import UIKit

struct MyLayoutItemsDataSource : LayoutItemsDataSource {
    
    typealias Item = MyCollectionViewItem
    typealias SectionType = [Item]
    typealias CreateSectionsType = ()->([SectionType])

    struct Metrics {
        let sectionMargin : CGFloat = 12
        var itemPadding: CGFloat = 40
        var sectionOffset : CGFloat = 10
    }
    let metrics = Metrics()
    
    private var sections = [SectionType]() {
        didSet {
            func calculateSize() ->CGSize {
                var width: CGFloat = 0.0
                if !sections.isEmpty
                {
                    let lastSectionFrame = frameForSectionAtIndex(sections.endIndex)
                    width = CGRectGetMaxX(lastSectionFrame) + metrics.sectionMargin
                }

                let height = [0..<sections.endIndex].mapWithIndex {index,section in self.frameForSectionAtIndex(index).size.height }
                    .reduce(0.0, combine: max)

                return CGSize(width: width, height: height)
            }
            size = calculateSize()
            items = sections.flatMap { $0 }
        }
    }
    
    var items:[Item]
    var size = CGSizeZero
    
    
    func frameForSectionAtIndex(index:Int) -> CGRect {
        let items = self.sections[index]
        let offset = metrics.sectionOffset * CGFloat(index)
        let maxSize = items.reduce(CGSizeZero) { accum, item in
            return CGSize(width: max(item.frame.size.width, accum.width), height: accum.height + item.frame.size.height + self.metrics.itemPadding)
        }
        return CGRectMake(offset, 0, maxSize.width, maxSize.height)
    }
    
    func sectionsInRect(rect:CGRect) -> [SectionType]
    {
        return self.sections.filterWithIndex {index,section in rect.contains(self.frameForSectionAtIndex(index).origin) }
    }

    func itemsForInRect(rect:CGRect) -> [Item] {
        return sectionsInRect(rect).flatMap { $0 } .filter({ rect.contains($0.frame) })
    }

    var createSections:CreateSectionsType
    init(createSections:CreateSectionsType) {
        self.createSections = createSections;
        self.items = []
        self.sections = [SectionType]()
    }
    
    mutating func prepare() {
        self.sections = self.createSections()
    }
}