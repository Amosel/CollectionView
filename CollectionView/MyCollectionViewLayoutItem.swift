import UIKit

enum MyCollectionViewItem : CollectionViewItem {
    case Normal(CGSize, NSIndexPath)
    case Connector(CGSize, NSIndexPath)
    var size:CGSize {
        switch self {
        case .Normal(let size, _):
            return size
        case .Connector(let size, _):
            return size
        }
    }
    var indexPath:NSIndexPath {
        switch self {
        case .Normal(_, let indexPath):
            return indexPath
        case .Connector(_, let indexPath):
            return indexPath
        }
    }
    var hashValue:Int {
        get  {
            return self.indexPath.hashValue
        }
    }
    var supplementaryItemDescription:SupplementaryItemDescripton? {
        switch self {
        case .Connector(_, _):
            return SupplementaryItemDescripton(kind:"Connector")
        default:
            return nil
        }
    }
}

func ==(lhs:MyCollectionViewItem, rhs:MyCollectionViewItem) -> Bool {
    return true
}

