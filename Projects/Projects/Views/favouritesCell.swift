//
//  favouritesCell.swift
//  Projects
//
//  Created by Group X on 22/10/18.
//  Copyright © 2018 USGBC. All rights reserved.
//

import UIKit

class favouritesCell: UITableViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
