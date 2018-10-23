//
//  thumbnail.swift
//  Projects
//
//  Created by Group X on 10/10/18.
//  Copyright © 2018 USGBC. All rights reserved.
//

import UIKit

class thumbnail: UITableViewCell {
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var thumbnailcount: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        thumbnailcount.font = UIFont.AktivGrotesk_Rg(size: 12)
        thumbnailcount.textColor = UIColor.white
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
