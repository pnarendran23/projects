//
//  Publication.swift
//  USGBC
//
//  Created by Vishal on 04/05/17.
//  Copyright © 2017 U.S Green Building Council. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

class Publication: Object{
    @objc dynamic var expirationDate = ""
    @objc dynamic var fileName = ""
    @objc dynamic var edition = ""
    @objc dynamic var image = ""
    @objc dynamic var fileKey = ""
    @objc dynamic var fid = ""
    @objc dynamic var fileDescription = ""
    @objc dynamic var type = ""
    @objc dynamic var publishedDate = ""
    @objc dynamic var ratingsystem = ""
    
    func initObject(json: JSON) {
        expirationDate = json["expirationDate"].stringValue
        fileName = json["fileName"].stringValue
        edition = json["edition"].stringValue
        image = json["image"].stringValue
        fileKey = json["fileKey"].stringValue
        fid = json["fid"].stringValue
        fileDescription = json["description"].stringValue
        type = json["type"].stringValue
        publishedDate = json["publishedDate"].stringValue
        ratingsystem = json["ratingsystem"].stringValue
        expirationDate = json["expirationDate"].stringValue
    }
}
