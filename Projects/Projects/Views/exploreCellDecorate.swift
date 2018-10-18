//
//  exploreCellDecorate.swift
//  
//
//  Created by Group X on 09/10/18.
//

import UIKit

class exploreCellDecorate: UITableViewCell {
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var category_image: UIImageView!
    
    @IBOutlet weak var counts: UILabel!
    @IBOutlet weak var categoryname: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
