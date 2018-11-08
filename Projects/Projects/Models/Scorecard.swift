//
//  Scorecard.swift
//  USGBC
//
//  Created by Pradheep Narendran on 31/08/17.
//  Copyright © 2017 U.S Green Building Council. All rights reserved.
//

import Foundation
import SwiftyJSON

class Scorecard {
    var name = ""
    var awarded = ""
    var possible = ""
    
    init() {}
    
    init(json: JSON){
        print(json)
        name = json["name"].stringValue
        awarded = json["awarded"].stringValue
        possible = json["possible"].stringValue
    }
    
    func getImage() -> String {
        var image = ""
        switch name {
            case "Sustainable sites":
                image = "ss"
            case "Water efficiency":
                image = "we"
            case "Energy & atmosphere":
                image = "ea"
            case "Material & resources":
                image = "mr"
            case "Indoor environmental quality":
                image = "iq"
            case "Location & transportation":
                image = "lt-border"
            case "Innovation":
                image = "id"
            case "Regional priority credits":
                image = "rp"
            case "Integrative process credits":
                image = "ip"
            case "Green infrastructure & buildings":
                image = "gi"
            case "Neighborhood pattern & design":
                image = "np"
            case "Smart location and linkage":
                image = "sl"
            default:
                break
            }
        return image
    }
}
