//
//  titlCell.swift
//  Projects
//
//  Created by Group X on 29/10/18.
//  Copyright © 2018 USGBC. All rights reserved.
//

import UIKit

class titleCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        title.textColor = UIColor(red:0.16, green:0.2, blue:0.23, alpha:1)
        title.font = UIFont.AktivGrotesk_Md(size: 20)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
