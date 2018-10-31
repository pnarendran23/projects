//
//  filterselected.swift
//  Projects
//
//  Created by Group X on 26/10/18.
//  Copyright © 2018 USGBC. All rights reserved.
//

import UIKit

class filterselected: UITableViewCell {
    @IBOutlet weak var lbl: UILabel!
    @IBOutlet weak var detaillbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            var frame = newValue
            frame.origin.x += 24
            frame.size.width -= 2 * 19
            
            super.frame = frame
        }
    }
    
}
