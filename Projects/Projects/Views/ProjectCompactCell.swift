//
//  ProjectCompactCollectionViewCell.swift
//  USGBC
//
//  Created by Pradheep Narendran on 20/08/17.
//  Copyright © 2017 U.S Green Building Council. All rights reserved.
//

import UIKit

class ProjectCompactCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var leedVersionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var certificationImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initViews()
    }
    
    func initViews(){
//        titleLabel.font = UIFont.gothamMedium(size: 14)
//        leedVersionLabel.font = UIFont.gothamBook(size: 12)
//        addressLabel.font = UIFont.gothamMedium(size: 12)
    }
    
    func updateViews(project: Project){
        let image = UIImage(named: "logo-usgbc-gray")
        //imageView.kf.setImage(with: URL(string: project.image), placeholder: image)
        imageView.clipsToBounds = true
        titleLabel.attributedText = Utility.linespacedString(string: project.title, lineSpace: 2)
        leedVersionLabel.text = project.rating_system_version
        var s = project.state
        var arr = s.components(separatedBy: " [")
        var state = ""
        if(arr.count == 2){
            state = arr[0] as! String
        }
        var s1 = project.country
        arr = s1.components(separatedBy: " [")
        var country = ""
        if(arr.count == 2){
            country = arr[0] as! String
        }
        addressLabel.text = "\(state), \(country)"
        certificationImageView.image = project.getCertificationLevelImage()
        if ( UI_USER_INTERFACE_IDIOM() == .pad ){
            separatorView.isHidden = true
        }
    }
}
