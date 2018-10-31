//
//  OperationsCell.swift
//  Projects
//
//  Created by Group X on 23/10/18.
//  Copyright © 2018 USGBC. All rights reserved.
//

import UIKit

class OperationsCell: UITableViewCell {
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
        //90,104, 114
                saveLbl.textColor = UIColor(red:0.35, green:0.41, blue:0.45, alpha:1)
                saveLbl.font = UIFont.AktivGrotesk_Rg(size: 14)
                directionsLbl.textColor = UIColor(red:0.35, green:0.41, blue:0.45, alpha:1)
                directionsLbl.font = UIFont.AktivGrotesk_Rg(size: 14)
                shareLbl.textColor = UIColor(red:0.35, green:0.41, blue:0.45, alpha:1)
                shareLbl.font = UIFont.AktivGrotesk_Rg(size: 14)
        
        var tintedImage = self.saveImage.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        self.saveImage.image = tintedImage
        self.saveImage.tintColor = UIColor(red:0.35, green:0.41, blue:0.45, alpha:1)
        
        tintedImage = self.directionsImage.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        self.directionsImage.image = tintedImage
        self.directionsImage.tintColor = UIColor(red:0.35, green:0.41, blue:0.45, alpha:1)
        
        tintedImage = self.shareImage.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        self.shareImage.image = tintedImage
        self.shareImage.tintColor = UIColor(red:0.35, green:0.41, blue:0.45, alpha:1)
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
