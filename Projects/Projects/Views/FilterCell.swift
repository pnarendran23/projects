//
//  FilterViewCell.swift
//  USGBC
//
//  Created by Pradheep Narendran on 21/08/17.
//  Copyright © 2017 U.S Green Building Council. All rights reserved.
//

import UIKit

class FilterCell: UITableViewCell {

    @IBOutlet weak var filterLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        filterLabel.textColor = UIColor(red:0.16, green:0.2, blue:0.23, alpha:1)
        filterLabel.font = UIFont.AktivGrotesk_Md(size: 16)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
