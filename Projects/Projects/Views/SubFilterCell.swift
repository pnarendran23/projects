//
//  SubFilterViewCell.swift
//  USGBC
//
//  Created by Pradheep Narendran on 21/08/17.
//  Copyright © 2017 U.S Green Building Council. All rights reserved.
//

import UIKit

class SubFilterCell: UITableViewCell {

    
    @IBOutlet weak var subFilterLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        subFilterLabel.textColor = UIColor(red:0.16, green:0.2, blue:0.23, alpha:1)
        subFilterLabel.font = UIFont.AktivGrotesk_Md(size: 16)

        initViews()
    }
    
    func initViews(){
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
