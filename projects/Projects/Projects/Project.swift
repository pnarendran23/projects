//
//  Project.swift
//  USGBC
//
//  Created by Vishal on 05/05/17.
//  Copyright © 2017 U.S Green Building Council. All rights reserved.
//

import Foundation
import SwiftyJSON

class Project: NSObject, NSCoding{
    var title = ""
    var certification_level = ""
    var rating_system_version = ""
    var image = ""
    var ID = ""
    var address = ""
    var lat = ""
    var long = ""
    var state = ""
    var country = ""
    override init() {}
    required init?(coder aDecoder: NSCoder) {
        // super.init(coder:) is optional, see notes below
        self.ID = aDecoder .decodeObject(forKey: "ID") as! String
        self.image = aDecoder.decodeObject(forKey: "image") as! String
        self.title = aDecoder.decodeObject(forKey: "title") as! String
        self.address = aDecoder.decodeObject(forKey: "address") as! String
        self.rating_system_version = aDecoder.decodeObject(forKey: "rating_system_version") as! String
        self.certification_level = aDecoder.decodeObject(forKey: "certification_level") as! String
        self.country = aDecoder.decodeObject(forKey: "country") as! String
        self.state = aDecoder.decodeObject(forKey: "state") as! String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(ID, forKey: "ID")
        aCoder.encode(image, forKey: "image")
        aCoder.encode(address, forKey: "address")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(rating_system_version, forKey: "rating_system_version")
        aCoder.encode(country, forKey: "country")
        aCoder.encode(state, forKey: "state")
        aCoder.encode(certification_level, forKey: "certification_level")        
    }
    
    init(json: JSON) {
        title = (json["title"].arrayValue.first?.stringValue)!
        certification_level = (json["field_prjt_certification_level"].arrayValue.first?.stringValue)!
        rating_system_version = (json["field_prjt_rating_system_version"].arrayValue.first?.stringValue)!
        image = (json["field_prjt_profile_image"].arrayValue.first?.stringValue)!
        ID = (json["field_prjt_id"].arrayValue.first?.stringValue)!
        address = (json["field_prjt_address"].arrayValue.first?.stringValue)!
        lat = (json["lat"].arrayValue.first?.stringValue)!
        long = (json["lng"].arrayValue.first?.stringValue)!
        if(json["field_prjt_country"].exists()){
            country =  (json["field_prjt_country"].arrayValue.first?.stringValue)!
        }else{
            country = ""
        }
        
        if(json["field_prjt_state"].exists()){
            state =  (json["field_prjt_state"].arrayValue.first?.stringValue)!
        }else{
            state = ""
        }
    }
    
    func getCertificationLevelImage() -> UIImage {
        var image = UIImage()
        if(certification_level == "Platinum"){
            image = UIImage(named: "platinum_project")!
        }else if(certification_level == "Gold"){
            image = UIImage(named: "gold_project")!
        }else if(certification_level == "Silver"){
            image = UIImage(named: "silver_project")!
        }else if(certification_level == "Certified"){
            image = UIImage(named: "certified_project")!
        }
        return image
    }
}
