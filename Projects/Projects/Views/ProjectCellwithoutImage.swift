//
//  ProjectCellwithoutImage.swift
//  Projects
//
//  Created by Group X on 09/10/18.
//  Copyright © 2018 USGBC. All rights reserved.
//

import UIKit

class ProjectCellwithoutImage: UITableViewCell {

//    @IBOutlet weak var address: UILabel!
//    @IBOutlet weak var projectname: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        sizeToFit()
        layoutIfNeeded()
        setNeedsLayout()
        updateConstraints()
        textLabel?.textColor = UIColor(red:0.16, green:0.2, blue:0.23, alpha:1)
        textLabel?.font = UIFont.AktivGrotesk_Md(size: 16)
//        address.font = UIFont.AktivGrotesk_Rg(size: 12)
//        address.textColor = UIColor(red:0.16, green:0.2, blue:0.23, alpha:1)
        
        // Initialization code
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            var frame = newValue
            frame.origin.x += 7
            frame.size.width -= 2 * 7
            
            super.frame = frame
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
