//
//  moreCollectionsView.swift
//  Projects
//
//  Created by Group X on 10/10/18.
//  Copyright © 2018 USGBC. All rights reserved.
//

import UIKit

class moreCollectionsView: UICollectionReusableView {
    @IBOutlet weak var moreCollections: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
            moreCollections.contentHorizontalAlignment = .right

        // Initialization code
    }
    
}
