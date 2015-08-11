import UIKit

class SchematicLayoutAttributes: UICollectionViewLayoutAttributes {
    var connectorLineStartTop: Bool = true
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        var copy = super.copyWithZone(zone) as! SchematicLayoutAttributes
        copy.connectorLineStartTop = self.connectorLineStartTop
        return copy
    }
}

class SchematicLayout {
    static var connectorViewKind:String {
        get {
            return "SchematicConnector"
        }
    }
}