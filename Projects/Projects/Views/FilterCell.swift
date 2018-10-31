//
//  FilterViewCell.swift
//  USGBC
//
//  Created by Pradheep Narendran on 21/08/17.
//  Copyright © 2017 U.S Green Building Council. All rights reserved.
//

import UIKit

class FilterCell: UITableViewCell {
    @IBOutlet weak var lbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.lbl.textColor = UIColor(red:0.16, green:0.2, blue:0.23, alpha:1)
        self.lbl.font = UIFont.AktivGrotesk_Md(size: 16)
        // Initialization code
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            var frame = newValue
            frame.origin.x += 27
            frame.size.width -= 2 * 19
            
            super.frame = frame
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
