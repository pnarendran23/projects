//
//  FavouritesHeader.swift
//  
//
//  Created by Group X on 20/10/18.
//

import UIKit

class FavouritesHeader: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        button.setTitle("", for: .normal)
        button.contentHorizontalAlignment = .right            
        // Initialization code
        label.textColor = UIColor(red:0.35, green:0.41, blue:0.45, alpha:1)
        label.font = UIFont.AktivGrotesk_Rg(size: 14)                
        button.titleLabel?.font = UIFont.AktivGrotesk_Rg(size: 14)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
