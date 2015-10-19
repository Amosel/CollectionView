import UIKit

protocol LayoutMetrics {
    var sectionMargin:CGFloat { get }
    var nodeSize:CGSize { get }
    var sectionPadding:CGFloat { get }
    init()
}

struct Metrics : CollectionViewLayoutMetrics, LayoutMetrics {
    var sectionMargin:CGFloat = 12
    var nodeSize = CGSizeMake(100, 100)
    var sectionPadding:CGFloat = 30
    init() {}
}

class CollectionViewController: UICollectionViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
        collectionView?.registerClass(SchematicConnectorView.self, forSupplementaryViewOfKind: SchematicLayout.connectorViewKind, withReuseIdentifier: SchematicConnectorView.viewReuseIdentifier)
        let dataController = SchematicDataController()
		dataController.performFetch()
        self.dataController = dataController
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
	}

    typealias Layout = CollectionViewLayout<Metrics>
//    typealias Layout = MyCollectionViewLayout <Metrics, AmosLayoutItemsProvider>
    
	var dataController:SchematicDataController? {
		didSet {
			let layout = Layout()
			layout.dataController = dataController
			self.layout = layout
		}
	}
    var layout:Layout? {
        didSet {
            if let layout = layout {
                self.collectionView?.collectionViewLayout = layout
                self.collectionView?.reloadData()
            }
        }
    }

    var sectionsMap:SchematicDataController.SectionMap? {
        get {
            return dataController?.sectionsMap
        }
    }
    
	override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return sectionsMap?.numberOfSections ?? 0
	}
	override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return sectionsMap?.numberOfRowsInSection(section) ?? 0
	}

	override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
	{
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SchematicNodeCell.cellReuseIdentifier, forIndexPath: indexPath) as! SchematicNodeCell
		cell.node = sectionsMap?.nodeAtIndexPath(indexPath)
		return cell
	}
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) ->
        UICollectionReusableView
    {
        return self.collectionView!.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: SchematicConnectorView.viewReuseIdentifier, forIndexPath: indexPath)
    }
}

