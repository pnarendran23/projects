//
//  exploreCell.swift
//  Projects
//
//  Created by Group X on 09/10/18.
//  Copyright © 2018 USGBC. All rights reserved.
//

import UIKit

class exploreCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = UIEdgeInsetsInsetRect(contentView.frame, UIEdgeInsetsMake(10, 10, 10, 10))
    }
    
}
