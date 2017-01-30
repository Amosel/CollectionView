import UIKit

class SchematicConnectorView : UICollectionReusableView {
    static let viewReuseIdentifier = "SchematicConnectorView"
    var lineStartTop: Bool = true
    override class var layerClass : AnyClass {
        return CAShapeLayer.self
    }
    var shapeLayer: CAShapeLayer {
        return self.layer as! CAShapeLayer
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    func sharedInit() {
        self.isOpaque = true
        self.shapeLayer.fillColor = nil
        self.shapeLayer.strokeColor = UIColor.lightGray.cgColor
        self.shapeLayer.lineWidth = 2.0
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? SchematicLayoutAttributes {
            self.lineStartTop = attributes.connectorLineStartTop
        }
    }

    override func layoutSubviews() {
        var start = CGPoint(x: self.bounds.minX, y: self.bounds.minY)
        var end = CGPoint(x: self.bounds.maxX, y: self.bounds.maxY)
        if self.lineStartTop {
            start.y = self.bounds.maxY
            end.y = self.bounds.minY
            }
            let path = UIBezierPath()
            path.move(to: start)
            path.addLine(to: end)
            self.shapeLayer.path = path.cgPath
        }
    }
