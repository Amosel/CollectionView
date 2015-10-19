import UIKit

enum MyCollectionViewItem : CollectionViewItem {
    case Normal(CGRect, NSIndexPath)
    case Connector(CGRect, NSIndexPath)
    
    var frame:CGRect {
        switch self {
        case .Normal(let frame, _):
            return frame
        case .Connector(let frame, _):
            return frame
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
    var layoutAttributes : UICollectionViewLayoutAttributes? {
        get {
            switch self {
            case .Normal(_, let indexPath):
                return UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            case .Connector(_, let indexPath):
                return SchematicLayoutAttributes(forSupplementaryViewOfKind:"Connector", withIndexPath: indexPath)
            }
        }
    }
    var supplementaryAttributesKind : String? {
        get {
            switch self {
            case .Normal:
                return nil
            case .Connector:
                return "Connector"
            }
        }
    }
    var supplementarylayoutAttributes : UICollectionViewLayoutAttributes? {
        get {
            switch self {
            case .Normal:
                return nil
            case .Connector:
                return nil
            }
        }
    }
}

func ==(lhs:MyCollectionViewItem, rhs:MyCollectionViewItem) -> Bool {
    return true
}

