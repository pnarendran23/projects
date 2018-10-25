//
//  expandCollapseCell.swift
//  Projects
//
//  Created by Group X on 11/10/18.
//  Copyright © 2018 USGBC. All rights reserved.
//

import UIKit

class expandCollapseCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var expandButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            var frame = newValue
            frame.origin.x += 25
            frame.size.width -= 2 * 25
            
            super.frame = frame
        }
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
