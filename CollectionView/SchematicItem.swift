//
//  SchematicItem.swift
//  CollectionView
//
//  Created by Amos Elmaliah on 1/29/17.
//  Copyright © 2017 Amos Elmaliah. All rights reserved.
//

import UIKit

enum SchematicItem : SectionDescriptionItemProtocol {
    case normal(CGSize, IndexSet)
    case connector(CGSize)
    var size: CGSize {
        switch self {
        case .normal(let size, _):
            return size
        case .connector(let size):
            return size
        }
    }
    var parents: IndexSet {
        switch self {
        case .normal(_, let parents):
            return parents
        default:
            return IndexSet()
        }
    }
    init(itemSize:CGSize, parents:IndexSet) {
        self = .normal(itemSize, parents)
    }
}
