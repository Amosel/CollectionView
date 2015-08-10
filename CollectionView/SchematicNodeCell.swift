import UIKit

extension Node.NodeType {
	var nodeColors:(label:UIColor, background:UIColor) {
		get {
			switch self {
			case .Normal:
				return (label:UIColor.blackColor(), background:UIColor.lightGrayColor())
			case .Important:
				return (label:UIColor.blackColor(), background:UIColor.yellowColor())
			case .Critical:
				return (label:UIColor.whiteColor(), background:UIColor.redColor())
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
			let colors = node?.nodeType.nodeColors ?? (label:UIColor.clearColor(), background:UIColor.clearColor())
			nameLabel.text = node?.name
			nameLabel.textColor = colors.label
			containerView.backgroundColor = colors.background
		}
	}
}
