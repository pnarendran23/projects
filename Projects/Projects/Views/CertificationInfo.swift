//
//  CertificationInfo.swift
//  Projects
//
//  Created by Group X on 10/10/18.
//  Copyright © 2018 USGBC. All rights reserved.
//

import UIKit

class CertificationInfo: UITableViewCell {
    @IBOutlet weak var certification_level: UILabel!
    @IBOutlet weak var certification_score: UILabel!
    @IBOutlet weak var certification_score_max: UILabel!
    @IBOutlet weak var rating_system: UILabel!
    @IBOutlet weak var size: UILabel!
    @IBOutlet weak var use: UILabel!
    @IBOutlet weak var setting: UILabel!
    @IBOutlet weak var certified: UILabel!
    @IBOutlet weak var walkscore: UILabel!
    @IBOutlet weak var energystar: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
