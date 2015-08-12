import UIKit

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

	var dataController:SchematicDataController? {
		didSet {
			let layout = CollectionViewLayout()
			layout.dataController = dataController
			self.layout = layout
		}
	}
    var layout:CollectionViewLayout? {
        didSet {
            if let layout = layout {
                self.collectionView?.collectionViewLayout = layout
                self.collectionView?.reloadData()
            }
        }
    }

	override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return self.dataController?.sections.count ?? 0
	}
	override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.dataController?.sections[section].count ?? 0
	}

	override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
	{
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SchematicNodeCell.cellReuseIdentifier, forIndexPath: indexPath) as! SchematicNodeCell
		cell.node = self.dataController?.nodeAtIndexPath(indexPath)
		return cell
	}
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) ->
        UICollectionReusableView
    {
        return self.collectionView!.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: SchematicConnectorView.viewReuseIdentifier, forIndexPath: indexPath)
    }
}

