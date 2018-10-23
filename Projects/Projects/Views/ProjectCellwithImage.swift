//
//  ProjectCellwithImage.swift
//  Projects
//
//  Created by Group X on 09/10/18.
//  Copyright © 2018 USGBC. All rights reserved.
//

import UIKit

class ProjectCellwithImage: UITableViewCell {    
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var projectname: UILabel!
    @IBOutlet weak var project_image: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        project_image.layer.cornerRadius = 2.0
        project_image.layer.masksToBounds = true
        projectname.textColor = UIColor(red:0.16, green:0.2, blue:0.23, alpha:1)
        projectname.font = UIFont.AktivGrotesk_Md(size: 16)
        address.font = UIFont.AktivGrotesk_Rg(size: 12)
        address.textColor = UIColor(red:0.16, green:0.2, blue:0.23, alpha:1)
       
            //UIFont(name: "AktivGrotesk-Medium", size: 16)!
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
