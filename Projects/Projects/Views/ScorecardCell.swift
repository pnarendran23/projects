//
//  ScorecardCell.swift
//  USGBC
//
//  Created by Pradheep Narendran on 31/08/17.
//  Copyright © 2017 U.S Green Building Council. All rights reserved.
//

import UIKit

class ScorecardCell: UITableViewCell {
    
    @IBOutlet weak var maxscoreLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var scoreImageView: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    
}
