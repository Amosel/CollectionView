import UIKit

class SchematicConnectorView : UICollectionReusableView {
    static let viewReuseIdentifier = "SchematicConnectorView"
    var lineStartTop: Bool = true
    override class func layerClass() -> AnyClass {
        return CAShapeLayer.self
    }
    var shapeLayer: CAShapeLayer {
        return self.layer as! CAShapeLayer
    }
    // ... INITILIZATION STRIPPED ...
    func sharedInit() {
        self.opaque = true
        self.shapeLayer.fillColor = nil
        self.shapeLayer.strokeColor = UIColor.lightGrayColor().CGColor
        self.shapeLayer.lineWidth = 2.0
    }
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)
        if let attributes = layoutAttributes as? SchematicLayoutAttributes {
            self.lineStartTop = attributes.connectorLineStartTop
        }
    }
    override func layoutSubviews() {
        var start = CGPoint(x: self.bounds.minX, y: self.bounds.minY)
        var end = CGPoint(x: self.bounds.maxX, y: self.bounds.maxY)
        if self.lineStartTop
{
            start.y = self.bounds.maxY
            end.y = self.bounds.minY
            }
            let path = UIBezierPath()
            path.moveToPoint(start)
            path.addLineToPoint(end)
            self.shapeLayer.path = path.CGPath
        }
    }