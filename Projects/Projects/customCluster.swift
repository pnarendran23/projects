//
//  customCluster.swift
//  Projects
//
//  Created by Group X on 08/11/18.
//  Copyright © 2018 USGBC. All rights reserved.
//

import UIKit

class customCluster: NSObject, GMUClusterIconGenerator {
    func icon(forSize size: UInt) -> UIImage! {
        return UIImage(named: "custom_marker")
    }
    
}
