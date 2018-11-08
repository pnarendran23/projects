//
//  projectInfo.swift
//  Projects
//
//  Created by Group X on 10/10/18.
//  Copyright © 2018 USGBC. All rights reserved.
//

import UIKit

class projectInfo: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        name.textColor = UIColor(red:0.16, green:0.2, blue:0.23, alpha:1)
        name.font = UIFont.AktivGrotesk_Md(size: 20)

        name.preferredMaxLayoutWidth = 200
        
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
