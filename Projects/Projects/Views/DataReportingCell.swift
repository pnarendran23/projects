//
//  DataReportingCell.swift
//  USGBC
//
//  Created by Pradheep Narendran on 31/08/17.
//  Copyright © 2017 U.S Green Building Council. All rights reserved.
//

import UIKit

class DataReportingCell: UITableViewCell {

    @IBOutlet weak var reportImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var updateButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateViews(dataReporting: DataReporting){
        
    }
    
}
