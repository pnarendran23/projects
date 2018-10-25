//
//  Aboutproject.swift
//  Projects
//
//  Created by Group X on 10/10/18.
//  Copyright © 2018 USGBC. All rights reserved.
//

import UIKit
import WebKit

class Aboutproject: UITableViewCell {
    @IBOutlet weak var webview: WKWebView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.webview.scrollView.bounces = false
        self.webview.scrollView.isScrollEnabled = false
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
