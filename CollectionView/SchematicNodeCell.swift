import UIKit

extension Node.NodeType {
	var nodeColors:(label: UIColor, background: UIColor) {
		get {
			switch self {
			case .normal:
				return (label:UIColor.black, background:UIColor.lightGray)
			case .important:
				return (label:UIColor.black, background:UIColor.yellow)
			case .critical:
				return (label:UIColor.white, background:UIColor.red)
			}
		}
	}
}

class SchematicNodeCell : UICollectionViewCell {
	static var cellReuseIdentifier:String  { get { return "Cell"} }
	@IBOutlet var nameLabel: UILabel!
	@IBOutlet var containerView: UIView!
	var node:Node? {
		didSet {
			let colors = node?.nodeType.nodeColors ?? (label:UIColor.clear, background:UIColor.clear)
			nameLabel.text = node?.name
			nameLabel.textColor = colors.label
			containerView.backgroundColor = colors.background
		}
	}
}
