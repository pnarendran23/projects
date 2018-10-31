//
//  stackCell.swift
//  Projects
//
//  Created by Group X on 30/10/18.
//  Copyright © 2018 USGBC. All rights reserved.
//

import UIKit

class stackCell: UITableViewCell {
    @IBOutlet weak var detaillbl: UILabel!
    @IBOutlet weak var lbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.textLabel?.textColor = UIColor(red:0.35, green:0.41, blue:0.45, alpha:1)
        self.textLabel?.font = UIFont.AktivGrotesk_Rg(size: 16)
        
        self.detailTextLabel?.textColor = UIColor(red:0.16, green:0.2, blue:0.23, alpha:1)
        self.detailTextLabel?.font = UIFont.AktivGrotesk_Rg(size: 16)
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            var frame = newValue
            frame.origin.x += 7
            frame.size.width -= 2 * 24
            
            super.frame = frame
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
