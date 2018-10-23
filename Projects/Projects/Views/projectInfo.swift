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
    @IBOutlet weak var saveLbl: UILabel!
    @IBOutlet weak var directionsLbl: UILabel!
    @IBOutlet weak var shareLbl: UILabel!
    @IBOutlet weak var saveImage: UIImageView!
    @IBOutlet weak var directionsImage: UIImageView!
    @IBOutlet weak var shareImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        name.textColor = UIColor(red:0.16, green:0.2, blue:0.23, alpha:1)
        name.font = UIFont.AktivGrotesk_Md(size: 20)
        line1.textColor = UIColor(red:0.16, green:0.2, blue:0.23, alpha:1)
        line1.font = UIFont.AktivGrotesk_Rg(size: 14)
        line2.textColor = UIColor(red:0.16, green:0.2, blue:0.23, alpha:1)
        line2.font = UIFont.AktivGrotesk_Rg(size: 14)
        saveLbl.textColor = UIColor(red:0.35, green:0.41, blue:0.45, alpha:1)
        saveLbl.font = UIFont.AktivGrotesk_Rg(size: 14)
        directionsLbl.textColor = UIColor(red:0.35, green:0.41, blue:0.45, alpha:1)
        directionsLbl.font = UIFont.AktivGrotesk_Rg(size: 14)
        shareLbl.textColor = UIColor(red:0.35, green:0.41, blue:0.45, alpha:1)
        shareLbl.font = UIFont.AktivGrotesk_Rg(size: 14)

        
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
