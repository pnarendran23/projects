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
        // Initialization code
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
