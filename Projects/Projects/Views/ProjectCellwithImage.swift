//
//  ProjectCellwithImage.swift
//  Projects
//
//  Created by Group X on 09/10/18.
//  Copyright © 2018 USGBC. All rights reserved.
//

import UIKit

class ProjectCellwithImage: UITableViewCell {
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var projectname: UILabel!
    @IBOutlet weak var project_image: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        project_image.layer.cornerRadius = 2.0
        project_image.layer.masksToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
