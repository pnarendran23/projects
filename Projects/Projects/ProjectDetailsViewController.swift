//
//  ProjectDetailsViewController.swift
//  Projects
//
//  Created by Group X on 10/10/18.
//  Copyright © 2018 USGBC. All rights reserved.
//

import UIKit
import Alamofire
import ImageViewer
import ParallaxHeader
import WebKit

class ProjectDetailsViewController: UIViewController, WKNavigationDelegate {
    @IBOutlet weak var tableView: UITableView!
    var expandDetails = false
    var items = [GalleryItem]()
    var scoreCard = [Scorecard]()
    var projectID = ""
    var expandSite = false
    var Details = ProjectDetails()
    var node_id = ""    
    var expandScoreCard = false
    var expandNearby = false
    override func viewDidLoad() {
        super.viewDidLoad()                
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.estimatedRowHeight = 400
        self.tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(UINib.init(nibName: "thumbnail", bundle: nil), forCellReuseIdentifier: "thumbnail")
        tableView.register(UINib.init(nibName: "projectInfo", bundle: nil), forCellReuseIdentifier: "projectInfo")
        tableView.register(UINib.init(nibName: "CertificationInfo", bundle: nil), forCellReuseIdentifier: "CertificationInfo")
        tableView.register(UINib.init(nibName: "Aboutproject", bundle: nil), forCellReuseIdentifier: "Aboutproject")
        tableView.register(UINib.init(nibName: "expandCollapseCell", bundle: nil), forCellReuseIdentifier: "expandCollapseCell")
        tableView.register(UINib.init(nibName: "ScorecardCell", bundle: nil), forCellReuseIdentifier: "ScorecardCell")
        
        
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.isTranslucent = true
//        self.navigationController?.view.backgroundColor = .clear
        self.navigationController?.navigationBar.tintColor = UIColor.black
        
        DispatchQueue.main.async {
            Utility.showLoading()
            self.tableView.isHidden = true
            self.getDetails(nodeid: self.node_id)
        }
        getDetails(projectID: projectID)
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationItem.title = "Hello"
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
//        self.navigationController?.navigationBar.isTranslucent = false
//        self.navigationController?.navigationBar.barTintColor = UIColor.white
//        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = self.tabBarController?.tabBar.tintColor
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


extension ProjectDetailsViewController : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 0){
            if(indexPath.row == 0){
                return 300
            }else if(indexPath.row == 1){
                return 202
            }else if(indexPath.row == 2){
                return 275
            }
        }
        else if(indexPath.section == 1){
            if(indexPath.row == 0){
                if(expandDetails){
                    return 800
                    //return UITableViewAutomaticDimension
                }else{
                    return 1
                }
            }
        }else if(indexPath.section == 2){
            if(indexPath.row == 0){
                if(expandSite){
                    return 70
                    //return UITableViewAutomaticDimension
                }else{
                    return 1
                }
            }
        }else if(indexPath.section == 3){
                if(expandScoreCard){
                    return UITableViewAutomaticDimension
                }else{
                    return 0
                }            
        }else if(indexPath.section == 4){
            if(indexPath.row == 0){
                if(expandNearby){
                    return 52
                }else{
                    return 1
                }
            }
        }
        return 40
    }
    

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section == 1 || section == 2 || section == 3 || section == 4 || section == 5){
            return 44
        }
        
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var title = ""
        if(section > 0){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "expandCollapseCell") as! expandCollapseCell
            cell.contentView.tag = 10 + section
            cell.contentView.addTapGesture(tapNumber: 1, target: self, action: #selector(headerTapped(view:)))
           cell.expandButton.tag = section
            var temp = false
            if(section == 1){
                title = "Details"
                temp = expandDetails
            }else if(section == 2){
                title = "Site context"
                temp = expandSite
            }else if(section == 3){
                title = "Score card"
                temp = expandScoreCard
            }else if(section == 4){
                title = "Projects nearby"
                temp = expandNearby
            }
            cell.title.text = "\(title)"
            if(temp){
                cell.expandButton.setImage(UIImage.init(named: "arrow_down"), for: .normal)
            }else{
                cell.expandButton.setImage(UIImage.init(named: "arrow_right"), for: .normal)
            }
            cell.expandButton.addTarget(self, action: #selector(expandCollapse(button:)), for: .touchUpInside)
            return cell
        }        
        return tableView.headerView(forSection: section)
    }
    
    @objc func headerTapped(view : UITapGestureRecognizer){
        print(view.view!.tag)
        if(view.view!.tag == 11){
            expandDetails = !expandDetails
        }else if(view.view!.tag == 12){
            expandSite = !expandSite
        }else if(view.view!.tag == 13){
            expandScoreCard = !expandScoreCard
        }else if(view.view!.tag == 14){
            expandNearby = !expandNearby
        }
        
        tableView.reloadData()
    }
    
    @objc func expandCollapse(button : UIButton){
        if(button.tag == 1){
            expandDetails = !expandDetails
        }else if(button.tag == 2){
            expandSite = !expandSite
        }else if(button.tag == 3){
            expandScoreCard = !expandScoreCard
        }else if(button.tag == 4){        
            expandNearby = !expandNearby
        }
        print(button.tag)
        tableView.reloadData()
        //tableView.scrollToRow(at: IndexPath.init(row: 0, section: button.tag), at: .top, animated: true)
        //self.tableView.beginUpdates()
        //self.tableView.reloadSections(IndexSet(integersIn: button.tag...button.tag), with: UITableViewRowAnimation.none)
        //self.tableView.endUpdates()
    }
        
        
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 1){
            return "Details"
        }else if(section == 2){
            return "Site Context"
        }
        
        return ""
    }
    
    func getDetails(projectID : String){
        Apimanager.shared.getProjectScorecard(id: projectID, callback:  { (scorecards, code) in
            if(code == -1 && scorecards != nil){
                print(scorecards)
                self.scoreCard = scorecards!
                self.tableView.reloadData()
            }else{
                
            }
        })
    }
    
    func getDetails(nodeid : String){
        print("Node id is ", nodeid)
        Apimanager.shared.getProjectDetails(id: nodeid, callback: {(projectDetails, code) in
            if(code == -1 && projectDetails != nil){
                    //self.totalCount = totalCount!
                DispatchQueue.main.async {
                    self.tableView.isHidden = false
                    self.Details = projectDetails!
                    self.Details.address = self.Details.address.replacingOccurrences(of: "\n", with: "")
                    Utility.hideLoading()
                    for s in self.Details.project_images{
                        self.items.append(GalleryItem.image { callback in
                            var url = URL.init(string: s)
                            let remoteImageURL = url
                            if(url != nil){
                            Alamofire.request(remoteImageURL!).responseData { (response) in
                                if response.error == nil {
                                    if let data = response.data {
                                        callback(UIImage(data: data))
                                    }
                                }else{
                                    callback(nil)
                                }
                            }
                            }
                        })
                    }
                    self.tableView.reloadData()
                }
                
            }else{
                if(code == 401){
                    
                }else if(code != -999 && code != nil && code != 0){
                    Utility.hideLoading()
                    if(self.navigationController != nil){
                        Utility.showToast(y: self.navigationController!.navigationBar.frame.size.height, message: "Something went wrong")
                    }
                }
            }
        })
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        if(indexPath.section == 0 && indexPath.row == 0){
            if(self.Details.project_images.count > 0){
                var gallery = GalleryViewController(startIndex: 0, itemsDataSource: self)
                gallery.toolbarItems = nil
                self.presentImageGallery(gallery)
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if(webView.tag == 71){

            //self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 3
        }
        
        if(section == 3){
            return scoreCard.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0){
            if(indexPath.row == 0){
                let thumbnailView = tableView.dequeueReusableCell(withIdentifier: "thumbnail", for: indexPath) as! thumbnail
                thumbnailView.selectionStyle = .none
                if(self.Details.project_images.count > 0){
                thumbnailView.imgView.sd_setImage(with: URL(string: self.Details.project_images.first!), placeholderImage: UIImage.init(named: "project_placeholder"))
                }else{
                    thumbnailView.imgView.image = UIImage.init(named: "project_placeholder")
                }
                thumbnailView.thumbnailcount.text = "\(self.Details.project_images.count)"
                
                return thumbnailView
            }else if(indexPath.row == 1){
                let projectInfoView = tableView.dequeueReusableCell(withIdentifier: "projectInfo", for: indexPath) as! projectInfo
                projectInfoView.name.text = self.Details.title
                projectInfoView.line1.text = self.Details.address
                projectInfoView.line2.text = "\(self.Details.city), \(self.Details.state), \(self.Details.country)"
                projectInfoView.saveView.addTapGesture(tapNumber: 1, target: self, action: #selector(save))
                projectInfoView.directionsView.addTapGesture(tapNumber: 1, target: self, action: #selector(direction))
                projectInfoView.shareView.addTapGesture(tapNumber: 1, target: self, action: #selector(share))
                projectInfoView.selectionStyle = .none
                return projectInfoView
            }else if(indexPath.row == 2){
                let CertificationInfoView = tableView.dequeueReusableCell(withIdentifier: "CertificationInfo", for: indexPath) as! CertificationInfo
                CertificationInfoView.selectionStyle = .none
                var justyear = ""
                if(self.Details.certification_date != ""){
                    var dateFormat = DateFormatter()
                    dateFormat.dateFormat = "MM/dd/yyyy"
                    var date = Date()
                    date = dateFormat.date(from: self.Details.certification_date)!
                    dateFormat.dateFormat = "yyyy"
                    justyear = dateFormat.string(from: date)
                    dateFormat.dateFormat = "dd MMM yyyy"
                    CertificationInfoView.certified.text = "\(dateFormat.string(from: date))"
                }
                CertificationInfoView.certification_level.text = "\(self.Details.project_certification_level.uppercased()) \(justyear)"
                CertificationInfoView.rating_system.text = self.Details.project_rating_system == "" ? "NA" : self.Details.project_rating_system
                CertificationInfoView.size.text = self.Details.project_size == "" ? "0 sf" : "\(self.Details.project_size) sf"
                CertificationInfoView.setting.text = self.Details.project_setting == "" ? "NA" : self.Details.project_setting
                CertificationInfoView.walkscore.text = self.Details.project_walkscore == "" ? "0" : self.Details.project_walkscore
                CertificationInfoView.energystar.text = self.Details.energy_star_score == "" ? "0" : self.Details.energy_star_score
                return CertificationInfoView
            }
        }else{
            if(indexPath.section == 1){
                if(indexPath.row == 0){
                    let AboutprojectView = tableView.dequeueReusableCell(withIdentifier: "Aboutproject", for: indexPath) as! Aboutproject
                    AboutprojectView.selectionStyle = .none
                    print(self.Details.description_full)
                    AboutprojectView.webview.loadHTMLString("<html><head></head><body>\(self.Details.description_full)</body></html>", baseURL: nil)
                    AboutprojectView.webview.tag = 70 + indexPath.section
                    AboutprojectView.webview.navigationDelegate = self
                    return AboutprojectView
                }
            }else if(indexPath.section == 2){
                if(indexPath.row == 0){
                    let AboutprojectView = tableView.dequeueReusableCell(withIdentifier: "Aboutproject", for: indexPath) as! Aboutproject
                    AboutprojectView.webview.loadHTMLString("<p>\(self.Details.site_context)</p>", baseURL: nil)
                    
                    AboutprojectView.selectionStyle = .none
                    return AboutprojectView
                }
            }else if(indexPath.section == 3){
                    let scorecardcellView = tableView.dequeueReusableCell(withIdentifier: "ScorecardCell", for: indexPath) as! ScorecardCell
                    scorecardcellView.titleLabel.text = "\(self.scoreCard[indexPath.row].name)"
                scorecardcellView.scoreLabel.text = "\(scoreCard[indexPath.row].awarded)"
                scorecardcellView.maxscoreLabel.text = "/\(scoreCard[indexPath.row].possible)"
                scorecardcellView.scoreImageView.image = UIImage(named: scoreCard[indexPath.row].getImage())
                    scorecardcellView.selectionStyle = .none
                    return scorecardcellView
            }
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        return cell
    }
    
    @objc func save(){
        print("Save")
    }
    
    @objc func direction(){
        print("Direction")
        var s =  Details.address
        if(s == ""){
            s = "U.S. Green Building Council"
        }
        s = s.replacingOccurrences(of: " ", with: "+")
        s = s.replacingOccurrences(of: "\n", with: "")
        let actionSheet = UIAlertController.init(title: "Please select the app which you want to open the Address", message: nil, preferredStyle: .actionSheet)
        
        
        let apple_maps = UIAlertAction.init(title: "Apple maps", style: UIAlertActionStyle.default, handler: { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(NSURL(string:
                        "http://maps.apple.com/?daddr=\(s)")! as URL, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                }
            }
        })
        
        let google_maps = UIAlertAction.init(title: "Google maps", style: UIAlertActionStyle.default, handler: { (action) in
            //self.showPhotoLibrary()
            
            if #available(iOS 10.0, *) {
                //UIApplication.shared.open(NSURL(string:"comgooglemaps://?q=\(s)")! as URL, options: [:] , completionHandler: nil)
                var s = "saddr=&daddr=\(self.Details.lat),\(self.Details.long)"
                UIApplication.shared.open(NSURL(string:"comgooglemaps://?\(s)")! as URL, options: [:] , completionHandler: nil)
                
            } else {
                // Fallback on earlier versions
            }
        })
        
        if (!UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)) {
            google_maps.isEnabled = false
        }
        
        actionSheet.addAction(google_maps)
        actionSheet.addAction(apple_maps)
        
        
        actionSheet.addAction(UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
            // self.dismissViewControllerAnimated(true, completion: nil) is not needed, this is handled automatically,
            //Plus whatever method you define here, gets called,
            //If you tap outside the UIAlertController action buttons area, then also this handler gets called.
        }))
        
        
        //self.presentViewController(shareMenu, animated: true, completion: nil)
        self.present(actionSheet, animated: true, completion: nil)
        
        
        
    }
    
    @objc func share(){
        // text to share
        let url = URL.init(string: "\(Apimanager.shared.projectDetailsURL)/projects/\(node_id)")
        
        // set up activity view controller
        let textToShare = [ url! ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
}

extension UIView {
    func addTapGesture(tapNumber: Int, target: Any, action: Selector) {
        let tap = UITapGestureRecognizer(target: target, action: action)
        tap.numberOfTapsRequired = tapNumber
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }
}

extension ProjectDetailsViewController: GalleryItemsDataSource {
    func itemCount() -> Int {
        return self.items.count
    }
    
    func provideGalleryItem(_ index: Int) -> GalleryItem {
        return self.items[index]
    }        
    
}
