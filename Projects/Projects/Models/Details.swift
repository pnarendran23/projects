//
//  Details.swift
//  USGBC
//
//  Created by Pradheep Narendran on 31/08/17.
//  Copyright © 2017 U.S Green Building Council. All rights reserved.
//

import Foundation
import SwiftyJSON

class Details {
    var key: String = ""
    var value: String = ""
    
    init() {}
    
    init(json: JSON) {
        key = json["key"].stringValue
        value = json["value"].stringValue
    }
}
