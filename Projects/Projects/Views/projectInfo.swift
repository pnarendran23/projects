//
//  projectInfo.swift
//  Projects
//
//  Created by Group X on 10/10/18.
//  Copyright © 2018 USGBC. All rights reserved.
//

import UIKit

class projectInfo: UITableViewCell {
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var directionButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var line1: UILabel!
    @IBOutlet weak var line2: UILabel!
    @IBOutlet weak var saveView: UIView!
    @IBOutlet weak var directionsView: UIView!
    @IBOutlet weak var shareView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
