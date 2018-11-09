//
//  rootController.swift
//  Projects
//
//  Created by Group X on 09/11/18.
//  Copyright © 2018 USGBC. All rights reserved.
//

import UIKit

class rootController: UINavigationController {

    override func viewDidLayoutSubviews() {
        for view in (self.navigationBar.subviews) {
            view.layoutMargins = UIEdgeInsets.zero
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
