//
//  ListHeader.swift
//  Projects
//
//  Created by Group X on 10/10/18.
//  Copyright © 2018 USGBC. All rights reserved.
//

import UIKit

class ListHeader: UITableViewCell {

    @IBOutlet weak var rightside: UILabel!
    @IBOutlet weak var projects: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        projects.text = ""
        rightside.text = ""
        projects.textColor = UIColor(red:0.35, green:0.41, blue:0.45, alpha:1)
        projects.font = UIFont.AktivGrotesk_Rg(size: 14)
        
        rightside.textColor = UIColor(red:0.35, green:0.41, blue:0.45, alpha:1)
        rightside.font = UIFont.AktivGrotesk_Rg(size: 14)
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
