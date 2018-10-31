//
//  expandCollapseCell.swift
//  Projects
//
//  Created by Group X on 11/10/18.
//  Copyright © 2018 USGBC. All rights reserved.
//

import UIKit

class expandCollapseCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var expandButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tintedImage = self.expandButton.imageView?.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        expandButton.setImage(tintedImage, for: .normal)
        expandButton.tintColor = UIColor.red
        title.text = ""
        // Initialization code
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
