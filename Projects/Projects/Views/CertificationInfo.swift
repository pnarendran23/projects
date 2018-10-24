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
    @IBOutlet weak var certificationheading: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var useLabel: UILabel!
    @IBOutlet weak var settingLabel: UILabel!
    @IBOutlet weak var certifiedLabel: UILabel!
    @IBOutlet weak var walkscoreLabel: UILabel!
    @IBOutlet weak var energystarLabel: UILabel!
    @IBOutlet weak var stack1: UIStackView!
    @IBOutlet weak var stack2: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        certificationheading.font = UIFont.AktivGrotesk_Md(size: 12)
        certificationheading.textColor = UIColor(red:0.35, green:0.41, blue:0.45, alpha:1)
        
        certification_level.font = UIFont.AktivGrotesk_Md(size: 16)
        certification_level.textColor = UIColor.black
      
        certification_score.font = UIFont.AktivGrotesk_Md(size: 16)
        certification_score.textColor = UIColor.black
        
        certification_score_max.font = UIFont.AktivGrotesk_Md(size: 16)
        certification_score_max.textColor = UIColor(red:0.53, green:0.6, blue:0.64, alpha:1)
        
        rating_system.font = UIFont.AktivGrotesk_Rg(size: 14)
        rating_system.textColor = UIColor(red:0.16, green:0.2, blue:0.23, alpha:1)
        
        
        size.textColor = UIColor(red:0.16, green:0.2, blue:0.23, alpha:1)
        size.font = UIFont.AktivGrotesk_Rg(size: 16)
        
        use.textColor = UIColor(red:0.16, green:0.2, blue:0.23, alpha:1)
        use.font = UIFont.AktivGrotesk_Rg(size: 16)
    
        setting.textColor = UIColor(red:0.16, green:0.2, blue:0.23, alpha:1)
        setting.font = UIFont.AktivGrotesk_Rg(size: 16)
   
        certified.textColor = UIColor(red:0.16, green:0.2, blue:0.23, alpha:1)
        certified.font = UIFont.AktivGrotesk_Rg(size: 16)
        
        walkscore.textColor = UIColor(red:0.16, green:0.2, blue:0.23, alpha:1)
        walkscore.font = UIFont.AktivGrotesk_Rg(size: 16)
        
        energystar.textColor = UIColor(red:0.16, green:0.2, blue:0.23, alpha:1)
        energystar.font = UIFont.AktivGrotesk_Rg(size: 16)
        
        sizeLabel.textColor = UIColor(red:0.53, green:0.6, blue:0.64, alpha:1)
        sizeLabel.font = UIFont.AktivGrotesk_Rg(size: 16)
        
        useLabel.textColor = UIColor(red:0.53, green:0.6, blue:0.64, alpha:1)
        useLabel.font = UIFont.AktivGrotesk_Rg(size: 16)
        
        settingLabel.textColor = UIColor(red:0.53, green:0.6, blue:0.64, alpha:1)
        settingLabel.font = UIFont.AktivGrotesk_Rg(size: 16)
        
        certifiedLabel.textColor = UIColor(red:0.53, green:0.6, blue:0.64, alpha:1)
        certifiedLabel.font = UIFont.AktivGrotesk_Rg(size: 16)
        
        walkscoreLabel.textColor = UIColor(red:0.53, green:0.6, blue:0.64, alpha:1)
        walkscoreLabel.font = UIFont.AktivGrotesk_Rg(size: 16)
        
        energystarLabel.textColor = UIColor(red:0.53, green:0.6, blue:0.64, alpha:1)
        energystarLabel.font = UIFont.AktivGrotesk_Rg(size: 16)
        
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
