//
//  expandCollapse.swift
//  Projects
//
//  Created by Group X on 23/10/18.
//  Copyright © 2018 USGBC. All rights reserved.
//

import UIKit

class expandCollapse: UITableViewHeaderFooterView {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var expandButton: UIButton!    
    
    override func awakeFromNib() {
            self.tintColor = UIColor.white
        self.backgroundView = UIView(frame: self.bounds)
        self.backgroundView?.backgroundColor = UIColor.white
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
