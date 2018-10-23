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
        
        titleLabel.textColor = UIColor(red:0.16, green:0.2, blue:0.23, alpha:1)
        titleLabel.font = UIFont.AktivGrotesk_Md(size: 14)
        
        maxscoreLabel.textColor = UIColor(red:0.53, green:0.6, blue:0.64, alpha:1)
        maxscoreLabel.font = UIFont.AktivGrotesk_Md(size: 16)
        
        scoreLabel.textColor = UIColor(red:0.16, green:0.2, blue:0.23, alpha:1)
        scoreLabel.font = UIFont.AktivGrotesk_Md(size: 16)

        
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    
}
