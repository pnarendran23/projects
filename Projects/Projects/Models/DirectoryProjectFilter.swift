//
//  DirectoryProjectFilter.swift
//  USGBC
//
//  Created by Pradheep Narendran on 24/08/17.
//  Copyright © 2017 U.S Green Building Council. All rights reserved.
//

import Foundation
import RealmSwift

class DirectoryProjectFilter: Object{
    @objc dynamic var name = ""
    @objc dynamic var value = ""
    @objc dynamic var selected = false
}
