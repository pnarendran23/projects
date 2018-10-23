//
//  exploreGridCell.swift
//  Projects
//
//  Created by Group X on 09/10/18.
//  Copyright © 2018 USGBC. All rights reserved.
//

import UIKit

class exploreGridCell: UICollectionViewCell {
    @IBOutlet weak var project_image: UIImageView!    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var counts: UILabel!
    @IBOutlet weak var category_image: UIButton!
 
    
    override func awakeFromNib() {
        self.contentView.layer.borderColor = UIColor.darkGray.cgColor
        self.contentView.layer.borderWidth = 0.4
        category_image.layer.cornerRadius = category_image.bounds.size.height/2.5
    }
    
}
