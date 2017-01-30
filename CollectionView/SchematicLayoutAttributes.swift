import UIKit

class SchematicLayoutAttributes : UICollectionViewLayoutAttributes {

    var connectorLineStartTop: Bool = true
    
    override func copy(with zone: NSZone?) -> Any {
        let copy = super.copy(with: zone) as! SchematicLayoutAttributes
        copy.connectorLineStartTop = self.connectorLineStartTop
        return copy
    }
}

class SchematicLayout {
    static var connectorViewKind: String {
        get {
            return "SchematicConnector"
        }
    }
}
