import UIKit

struct Metrics : CollectionViewLayoutMetrics {
    var sectionMargin:CGFloat = 12
    var itemSize = CGSize(width: 100, height: 100)
    var sectionPadding:CGFloat = 30
}


class CollectionViewController: UICollectionViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
        collectionView?.register(SchematicConnectorView.self, forSupplementaryViewOfKind: SchematicLayout.connectorViewKind, withReuseIdentifier: SchematicConnectorView.viewReuseIdentifier)
        let dataController = SchematicDataController()
		dataController.performFetch()
        self.dataController = dataController
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

    typealias Layout = CollectionViewLayout<Metrics, SchematicDataController>
    
	var dataController: SchematicDataController? {
		didSet {
			let layout = Layout()
			layout.dataController = dataController
			self.layout = layout
		}
	}
    var layout: Layout? {
        didSet {
            if let layout = layout {
                self.collectionView?.collectionViewLayout = layout
                self.collectionView?.reloadData()
            }
        }
    }
    var sectionsMap: SchematicDataController.SectionMap? {
        get {
            return dataController?.sectionsMap
        }
    }
    
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return sectionsMap?.numberOfSections ?? 0
	}
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectionsMap?.numberOfRows(in: section) ?? 0
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
	{
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SchematicNodeCell.cellReuseIdentifier, for: indexPath
            ) as! SchematicNodeCell
		cell.node = sectionsMap?.element(at: indexPath)
		return cell
	}
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) ->
        UICollectionReusableView
    {
        return self.collectionView!.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SchematicConnectorView.viewReuseIdentifier, for: indexPath)
    }
}

