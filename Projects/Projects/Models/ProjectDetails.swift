//
//  ProjectDetails.swift
//  USGBC
//
//  Created by Pradheep Narendran on 25/10/17.
//  Copyright © 2017 U.S Green Building Council. All rights reserved.
//

import Foundation
import SwiftyJSON

class ProjectDetails {
    var title = ""
    var post_date = ""
    var certification_date = ""
    var certificate_date_medium = ""
    var project_id = ""
    var project_setting = ""
    var project_type = ""
    var project_walkscore = ""
    var project_size = ""
    var description_full = ""
    var site_context = ""
    var image = ""
    var energy_star_score = ""
    var project_images = [String]()
    var city = ""
    var project_certification_level = ""
    var project_rating_system_version = ""
    var address = ""
    var state = ""
    var country = ""
    var story = ""
    var lat = ""
    var long = ""
    var project_rating_system = ""
    var rating_system_full = ""
    var rating_version_full = ""
    var transportation_score = 0
    var waste_score = 0
    var energy_score = 0
    var water_score = 0
    var human_score = 0
    var path = ""
    
    init() {}
    
    init(json: JSON) {
        print(json)
        title = json["Title"].stringValue
        post_date = json["post_date"].stringValue
        certification_date = json["certification_date"].stringValue
        certificate_date_medium = json["certificate_date_medium"].stringValue
        project_id = json["project_id"].stringValue
        project_setting = json["project_setting"].stringValue
        project_type = json["project_type"].stringValue
        project_walkscore = json["project_walkscore"].stringValue
        project_size = json["project_size"].stringValue
        description_full = json["description_full"].stringValue
        image = json["profile_image"].stringValue
        project_certification_level = json["project_certification_level"].stringValue
        project_rating_system_version = json["project_rating_system_version"].stringValue
        address = json["address"].stringValue
        lat = json["lat"].stringValue
        long = json["long"].stringValue
        project_rating_system = json["project_rating_system"].stringValue
        rating_system_full = json["rating_system_full"].stringValue
        rating_version_full = json["rating_version_full"].stringValue
        transportation_score = json["transportation_score"].intValue
        waste_score = json["waste_score"].intValue
        energy_score = json["energy_score"].intValue
        water_score = json["water_score"].intValue
        human_score = json["human_score"].intValue
        path = json["path"].stringValue
    }
    
    func getCertificationLevelImage() -> UIImage {
        var image = UIImage()
        if(project_certification_level == "Platinum"){
            image = UIImage(named: "platinum_project")!
        }else if(project_certification_level == "Gold"){
            image = UIImage(named: "gold_project")!
        }else if(project_certification_level == "Silver"){
            image = UIImage(named: "silver_project")!
        }else if(project_certification_level == "Certified"){
            image = UIImage(named: "certified_project")!
        }
        return image
    }
}
