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
import SwiftyJSON
import RealmSwift

class ProjectDetailsViewController: UIViewController, WKNavigationDelegate {
    @IBOutlet weak var tableView: UITableView!
    var favourites = [Project]()
    var heights : [CGFloat] = [0.0]
    var isFavourite = false
    var titleArray = [String]()
    var expandDetails = false
    var items = [GalleryItem]()
    var currentProject = Project()
    var currentLocation: CLLocation?
    var maxScore = 110
    var latitude = 0.0
    var nearbyprojects = [Project]()
    var longitude = 0.0
    var currentScore = 0
    var scoreCard = [Scorecard]()
    var projectID = ""
    var expandSite = false
    var Details = ProjectDetails()
    var node_id = ""    
    var expandScoreCard = false
    var expandNearby = false
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Selected node ID is ", node_id)
        tableView.register(UINib(nibName: "ProjectCellwithImage", bundle: nil), forCellReuseIdentifier: "ProjectCellwithImage")
        tableView.register(UINib(nibName: "ProjectCellwithoutImage", bundle: nil), forCellReuseIdentifier: "ProjectCellwithoutImage")
        tableView.register(UINib(nibName: "ListHeader", bundle: nil), forCellReuseIdentifier: "ListHeader")
        if #available(iOS 11.0, *) {
            //self.tableView.contentInsetAdjustmentBehavior = .never;
        } else {
            self.automaticallyAdjustsScrollViewInsets = false;
        }
        tableView.contentInset = .zero
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
        
        
        
        DispatchQueue.main.async {
            Utility.showLoading()
            self.tableView.isHidden = true
            self.getDetails(nodeid: self.node_id)
        }
        getDetails(projectID: projectID)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        UserDefaults.standard.synchronize()
        isFavourite = false
        if(UserDefaults.standard.object(forKey: "favourites") != nil){
            self.favourites = NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "favourites") as! Data) as! [Project]
            for i in self.favourites{
                if(i.ID == self.currentProject.ID){
                    isFavourite = true
                    break
                }
                print(i.title)
            }
            self.tableView.reloadData()
        }
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = textAttributes        
        self.navigationController?.navigationBar.tintColor = UIColor.black
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
//        self.navigationController?.navigationBar.isTranslucent = false
//        self.navigationController?.navigationBar.barTintColor = UIColor.white
//        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = self.tabBarController?.tabBar.tintColor
        Apimanager.shared.stopAllSessions()
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
        var noofsections = 1
        titleArray = [String]()
        titleArray.append("")
        if(self.Details.description_full.count > 0){
            titleArray.append("Details")
            noofsections = noofsections + 1
        }
        if(self.scoreCard.count > 0){
            titleArray.append("Scorecard")
            noofsections = noofsections + 1
        }
        if(self.nearbyprojects.count > 0){
            titleArray.append("Projects nearby")
            noofsections = noofsections + 1
        }
        
        return noofsections
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(titleArray[indexPath.section] == ""){
            
            if(self.Details.project_images.count > 0){
                if(indexPath.row == 0){
                    return 300
                }else if(indexPath.row == 1){
                    return 202
                }else if(indexPath.row == 2){
                    return 275
                }
            }else{
                if(indexPath.row == 0){
                    return 202
                }else if(indexPath.row == 1){
                    return 275
                }
            }
        }
        else if(titleArray[indexPath.section] == "Details"){
            if(indexPath.row == 0){
                if(expandDetails){
                    if(Details.description_full.count == 0){
                        return 1
                    }
                    return heights[0]
                    //return UITableViewAutomaticDimension
                }else{
                    return 0
                }
            }
        }else if(titleArray[indexPath.section] == "Scorecard"){
                if(expandScoreCard){
                    return UITableViewAutomaticDimension
                }else{
                    return 0
                }            
        }else if(titleArray[indexPath.section] == "Projects nearby"){
                if(expandNearby){
                     return UITableViewAutomaticDimension
                }else{
                    return 0
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
            title = titleArray[section]
            if(titleArray[section] == "Details"){
                temp = expandDetails
            }else if(titleArray[section] == "Scorecard"){
                temp = expandScoreCard
            }else if(titleArray[section] == "Projects nearby"){
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
        var scroll = false
        if(titleArray[view.view!.tag - 10] == "Details"){
            expandDetails = !expandDetails
            if(!expandDetails){
                scroll = true
            }
        }else if(titleArray[view.view!.tag - 10] == "Scorecard"){
            expandScoreCard = !expandScoreCard
            if(!expandScoreCard){
                scroll = true
            }
        }else if(titleArray[view.view!.tag - 10] == "Projects nearby"){
            expandNearby = !expandNearby
            if(!expandNearby){
                scroll = true
            }
        }
        tableView.reloadData()
        if(scroll == true){
            tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    @objc func expandCollapse(button : UIButton){
        print(button.tag)
        var scroll = false
        if(titleArray[button.tag] == "Details"){
            expandDetails = !expandDetails
            if(!expandDetails){
                scroll = true
            }
        }else if(titleArray[button.tag] == "Scorecard"){
            expandScoreCard = !expandScoreCard
            if(!expandScoreCard){
                scroll = true
            }
        }else if(titleArray[button.tag] == "Projects nearby"){
            expandNearby = !expandNearby
            if(!expandNearby){
                scroll = true
            }
        }
        tableView.reloadData()
        if(scroll == true){
            tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
        }
        //tableView.scrollToRow(at: IndexPath.init(row: 0, section: button.tag), at: .top, animated: true)
        //self.tableView.beginUpdates()
        //self.tableView.reloadSections(IndexSet(integersIn: button.tag...button.tag), with: UITableViewRowAnimation.none)
        //self.tableView.endUpdates()
    }
        
        
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        return ""
    }
    
    func getDetails(projectID : String){
        Apimanager.shared.getProjectScorecard(id: projectID, callback:  { (scorecards, code) in
            if(code == -1 && scorecards != nil){
                print(scorecards)
                var scoreCards: [Scorecard] = scorecards!
                if(scorecards!.count > 0){
                    self.scoreCard = scorecards!
                }else{
                  var temp = [
                        [
                            "name": "Sustainable sites",
                            "awarded": 0,
                            "possible": 14
                        ],
                        [
                            "name": "Water efficiency",
                            "awarded": 0,
                            "possible": 5
                        ],
                        [
                            "name": "Energy & atmosphere",
                            "awarded": 0,
                            "possible": 17
                        ],
                        [
                            "name": "Material & resources",
                            "awarded": 0,
                            "possible": 13
                        ],
                        [
                            "name": "Indoor environmental quality",
                            "awarded": 0,
                            "possible": 15
                        ],
                        [
                            "name": "Innovation",
                            "awarded": 0,
                            "possible": 5
                        ]
                    ]
                    
                    
                    for i in temp{
                        var tempscorecard = Scorecard()
                        var dict = i as! NSDictionary
                        tempscorecard.awarded = "\(dict["awarded"] as! Int)"
                        tempscorecard.name = dict["name"] as! String
                        tempscorecard.possible = "\(dict["possible"] as! Int)"
                        scoreCards.append(tempscorecard)
                    }
                    
                }
                self.scoreCard = scoreCards
                
                for i in self.scoreCard{
                    self.currentScore = self.currentScore + Int(i.awarded)!
                    self.maxScore = self.currentScore + Int(i.possible)!
                }
                self.tableView.reloadData()
            }else{
                print(scorecards)
                var temp = [
                    [
                        "name": "Sustainable sites",
                        "awarded": 0,
                        "possible": 14
                    ],
                    [
                        "name": "Water efficiency",
                        "awarded": 0,
                        "possible": 5
                    ],
                    [
                        "name": "Energy & atmosphere",
                        "awarded": 0,
                        "possible": 17
                    ],
                    [
                        "name": "Material & resources",
                        "awarded": 0,
                        "possible": 13
                    ],
                    [
                        "name": "Indoor environmental quality",
                        "awarded": 0,
                        "possible": 15
                    ],
                    [
                        "name": "Innovation",
                        "awarded": 0,
                        "possible": 5
                    ]
                ]
                
                var scoreCards: [Scorecard] = []
                
                for i in temp{
                    var tempscorecard = Scorecard()
                    var dict = i as! NSDictionary
                    tempscorecard.awarded = "\(dict["awarded"] as! Int)"
                    tempscorecard.name = dict["name"] as! String
                    tempscorecard.possible = "\(dict["possible"] as! Int)"
                    scoreCards.append(tempscorecard)
                }
                
                self.scoreCard = scoreCards
                
                for i in self.scoreCard{
                    self.currentScore = self.currentScore + Int(i.awarded)!
                    self.maxScore = self.currentScore + Int(i.possible)!
                }
                self.tableView.reloadData()
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
                    self.latitude = CLLocationDegrees(self.Details.lat)!
                    self.longitude = CLLocationDegrees(self.Details.long)!
//                    if(self.Details.project_images.count == 0){
//                        self.navigationController?.navigationBar.tintColor = UIColor.black
//                    }else{
//                        self.navigationController?.navigationBar.tintColor = UIColor.white
//                    }
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
                    self.getNearbyProjects()
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
    
    func getNearbyProjects(){
        var dict = [[String : [String : String]]]()
        dict = ViewController().constructCategory()
        Apimanager.shared.getProjectsElasticForMapNew (from: 0, sizee : 6, search : "", category : dict, lat : latitude, lng : longitude, distance : 500, callback: {(totalRecords, projects, code) in
            if(code == -1 && projects != nil){
                //self.totalRecords = totalRecords!
                self.nearbyprojects = [Project]()
                
                for i in projects!{
                    if(i.node_id != self.node_id){
                        self.nearbyprojects.append(i)
                    }else{
                    }
                }
                //self.lastRecordsCount = projects!.count
                //self.filterProjects = self.projects
                DispatchQueue.main.async {
                    Utility.hideLoading()
                    self.tableView.reloadData()
                }
            }else{
                if(code == 401){
                    
                }else if(code != -999 && code != nil && code != 0 && code != 200){
                    DispatchQueue.main.async {
                        Utility.hideLoading()
                    }
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
        var h = CGFloat(0)
        if(self.heights[0] > 0){
            return
        }
        webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
            if complete != nil {
                webView.frame.size.height = 1
                webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
                    h = height! as! CGFloat
                    print(height!)
                    print(h)
                    self.heights[0] = h
                    self.tableView.reloadData()
                })
            }
            
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(titleArray[section] == ""){
            var size = 2
            if(self.Details.project_images.count > 0){
                size = size + 1
            }
            return size
        }else if(titleArray[section] == "Details"){
            if(!expandDetails){
                return 0
            }
            return 1
        }else if(titleArray[section] == "Scorecard"){
            if(!expandScoreCard){
                return 0
            }
            return self.scoreCard.count
        }else if(titleArray[section] == "Projects nearby"){
            if(!expandNearby){
                return 0
            }
            return self.nearbyprojects.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(titleArray[indexPath.section] == ""){
            if(self.Details.project_images.count > 0){
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
                    self.Details.address.replacingOccurrences(of: "\n", with: ", ")
                    projectInfoView.line1.text = self.Details.address
                    projectInfoView.line2.text = "\(self.Details.city), \(self.Details.state), \(self.Details.country)"
                    if(isFavourite == false){
                        projectInfoView.saveImage.image = UIImage.init(named: "Favorites_BU")
                        projectInfoView.saveLbl.text = "Save"
                    }else{
                        projectInfoView.saveImage.image = UIImage.init(named: "Favorites_Active_BU")
                        projectInfoView.saveLbl.text = "Saved"
                    }
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
                    CertificationInfoView.use.text = "\(self.Details.project_type)"
                    CertificationInfoView.setting.text = "\(self.Details.project_setting)"
                    CertificationInfoView.certification_score_max.text = "/\(self.maxScore)"
                    CertificationInfoView.certification_score.text = "\(self.currentScore)"
                    
                    
                    var attr = NSMutableAttributedString.init(string: "\(currentScore)")
                    let attributed = NSMutableAttributedString.init(string: "/\(maxScore)")
                    attributed.addAttributes([NSAttributedStringKey.foregroundColor: CertificationInfoView.certification_score_max.textColor], range: NSMakeRange(0, "/\(maxScore)".count ))
                    
                    attr.append(attributed)
                    
                    CertificationInfoView.certification_score.attributedText = attr
                    let numberFormatter = NumberFormatter()
                    numberFormatter.numberStyle = NumberFormatter.Style.decimal
                    var formattedNumber = ""
                    if(Details.project_size != ""){
                        formattedNumber = numberFormatter.string(from: NSNumber(value:Int(self.Details.project_size)!))!
                    }
                    CertificationInfoView.size.text = self.Details.project_size == "" ? "0 sf" : "\(formattedNumber) sf"
                    CertificationInfoView.setting.text = self.Details.project_setting == "" ? "NA" : self.Details.project_setting
                    CertificationInfoView.walkscore.text = self.Details.project_walkscore == "" ? "0" : self.Details.project_walkscore
                    CertificationInfoView.energystar.text = self.Details.energy_star_score == "" ? "0" : self.Details.energy_star_score
                    return CertificationInfoView
                }
            }else{
               if(indexPath.row == 0){
                    let projectInfoView = tableView.dequeueReusableCell(withIdentifier: "projectInfo", for: indexPath) as! projectInfo
                    projectInfoView.name.text = self.Details.title
                    self.Details.address.replacingOccurrences(of: "\n", with: ", ")
                    projectInfoView.line1.text = self.Details.address
                    projectInfoView.line2.text = "\(self.Details.city), \(self.Details.state), \(self.Details.country)"
                    if(isFavourite == false){
                        projectInfoView.saveImage.image = UIImage.init(named: "Favorites_BU")
                        projectInfoView.saveLbl.text = "Save"
                    }else{
                        projectInfoView.saveImage.image = UIImage.init(named: "Favorites_Active_BU")
                        projectInfoView.saveLbl.text = "Saved"
                    }
                    projectInfoView.saveView.addTapGesture(tapNumber: 1, target: self, action: #selector(save))
                    projectInfoView.directionsView.addTapGesture(tapNumber: 1, target: self, action: #selector(direction))
                    projectInfoView.shareView.addTapGesture(tapNumber: 1, target: self, action: #selector(share))
                    projectInfoView.selectionStyle = .none
                    return projectInfoView
                }else if(indexPath.row == 1){
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
                    CertificationInfoView.use.text = "\(self.Details.project_type)"
                    CertificationInfoView.setting.text = "\(self.Details.project_setting)"
                    CertificationInfoView.certification_score_max.text = "/\(self.maxScore)"
                    CertificationInfoView.certification_score.text = "\(self.currentScore)"
                    
                    
                    var attr = NSMutableAttributedString.init(string: "\(currentScore)")
                    let attributed = NSMutableAttributedString.init(string: "/\(maxScore)")
                    attributed.addAttributes([NSAttributedStringKey.foregroundColor: CertificationInfoView.certification_score_max.textColor], range: NSMakeRange(0, "/\(maxScore)".count ))
                    
                    attr.append(attributed)
                    
                    CertificationInfoView.certification_score.attributedText = attr
                    let numberFormatter = NumberFormatter()
                    numberFormatter.numberStyle = NumberFormatter.Style.decimal
                    var formattedNumber = ""
                    if(Details.project_size != ""){
                        formattedNumber = numberFormatter.string(from: NSNumber(value:Int(self.Details.project_size)!))!
                    }
                    CertificationInfoView.size.text = self.Details.project_size == "" ? "0 sf" : "\(formattedNumber) sf"
                    CertificationInfoView.setting.text = self.Details.project_setting == "" ? "NA" : self.Details.project_setting
                    CertificationInfoView.walkscore.text = self.Details.project_walkscore == "" ? "0" : self.Details.project_walkscore
                    CertificationInfoView.energystar.text = self.Details.energy_star_score == "" ? "0" : self.Details.energy_star_score
                    return CertificationInfoView
                }
            }
        }else{
            if(titleArray[indexPath.section] == "Details"){
                if(indexPath.row == 0){
                    let AboutprojectView = tableView.dequeueReusableCell(withIdentifier: "Aboutproject", for: indexPath) as! Aboutproject
                    AboutprojectView.selectionStyle = .none
                    print(self.Details.description_full)
                    AboutprojectView.webview.loadHTMLString("<html><head><meta name='viewport' content='initial-scale=1.0, user-scalable=no, width=device-width, viewport-fit=cover'/><style>body{font-family: 'Aktiv Grotesk Trial'}</style></head><body>\(self.Details.description_full)</body></html>", baseURL: nil)
                    AboutprojectView.webview.tag = 70 + indexPath.section
                    AboutprojectView.webview.scrollView.layer.masksToBounds = false
                    AboutprojectView.webview.navigationDelegate = self
                    return AboutprojectView
                }
            }else if(titleArray[indexPath.section] == "Scorecard"){
                    let scorecardcellView = tableView.dequeueReusableCell(withIdentifier: "ScorecardCell", for: indexPath) as! ScorecardCell
                    scorecardcellView.titleLabel.text = "\(self.scoreCard[indexPath.row].name)"
                var attr = NSMutableAttributedString.init(string: "\(scoreCard[indexPath.row].awarded)")
                let attributed = NSMutableAttributedString.init(string: "/\(scoreCard[indexPath.row].possible)")
                attributed.addAttributes([NSAttributedStringKey.foregroundColor: scorecardcellView.maxscoreLabel.textColor], range: NSMakeRange(0, "/\(scoreCard[indexPath.row].possible)".count ))
                
                attr.append(attributed)
                
                scorecardcellView.scoreLabel.attributedText = attr
                //scorecardcellView.maxscoreLabel.text = "/\(scoreCard[indexPath.row].possible)"
                scorecardcellView.scoreImageView.image = UIImage(named: scoreCard[indexPath.row].getImage())
                    scorecardcellView.selectionStyle = .none
                    return scorecardcellView
            }else if(titleArray[indexPath.section] == "Projects nearby"){
                    let project = nearbyprojects[indexPath.row]
                    var tempLocation = currentLocation
                    if(project.lat != "" && project.long != ""){
                        tempLocation = CLLocation.init(latitude: Double(project.lat)!, longitude: Double(project.long)!)
                    }
                    if(project.image.count > 0 && !project.image.contains("project_placeholder")){
                        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCellwithImage", for: indexPath) as! ProjectCellwithImage
                        //cell.projectname.text = "\(project.title)"
                        let normalText  = "\(project.title)"
                        let attributedString = NSMutableAttributedString(string:normalText)
                        var distance = ""
                        if(tempLocation!.distance(from: currentLocation!) < 1000){
                            distance = "\(Double(round(tempLocation!.distance(from: currentLocation!) * 100)/100)) mi. away"
                        }else{
                            distance = "1000+ mi. away"
                        }
                        var boldText = "\n\(project.state), \(project.country)\n\(distance)"
                        var mutableParagraphStyle = NSMutableParagraphStyle()
                        // Customize the line spacing for paragraph.
                        mutableParagraphStyle.lineSpacing = CGFloat(5)
                        //bold.addAttribute(NSAttributedStringKey.paragraphStyle , value: mutableParagraphStyle, range: NSMakeRange(0, boldText.count))
                        
                        
                        let attrs = [NSAttributedStringKey.font : cell.address.font] as [NSAttributedStringKey : Any]
                        var boldString = NSMutableAttributedString(string: boldText, attributes:attrs)
                        boldString.addAttribute(NSAttributedStringKey.paragraphStyle , value: mutableParagraphStyle, range: NSMakeRange("\n\(project.state), \(project.country)".count, distance.count))
                        mutableParagraphStyle = NSMutableParagraphStyle()
                        // Customize the line spacing for paragraph.
                        mutableParagraphStyle.lineSpacing = CGFloat(30)
                        
                        boldString.addAttribute(NSAttributedStringKey.paragraphStyle , value: mutableParagraphStyle, range: NSMakeRange("\n\(project.state), \(project.country)".count, distance.count))
                        attributedString.append(boldString)
                        cell.projectname.attributedText = attributedString
                        //cell.address.text = "\(project.address.replacingOccurrences(of: "\n", with: ""))"
                        cell.project_image.center.y = cell.contentView.frame.size.height/2
                        cell.project_image.sd_setImage(with: URL(string: project.image), placeholderImage: UIImage.init(named: "project_placeholder"))
                        
                        return cell
                    }else{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCellwithoutImage", for: indexPath) as! ProjectCellwithoutImage
                        //cell.address.text = "\(project.address.replacingOccurrences(of: "\n", with: ""))"
                        let normalText  = "\(project.title)"
                        
                        let attributedString = NSMutableAttributedString(string:normalText)
                        
                        var distance = ""
                        if(tempLocation!.distance(from: currentLocation!) < 1000){
                            distance = "\(Double(round(tempLocation!.distance(from: currentLocation!) * 100)/100)) mi. away"
                        }else{
                            distance = "1000+ mi. away"
                        }
                        var boldText = "\n\(project.state), \(project.country)\n\(distance)"
                        var mutableParagraphStyle = NSMutableParagraphStyle()
                        // Customize the line spacing for paragraph.
                        mutableParagraphStyle.lineSpacing = CGFloat(5)
                        //bold.addAttribute(NSAttributedStringKey.paragraphStyle , value: mutableParagraphStyle, range: NSMakeRange(0, boldText.count))
                        
                        
                        let attrs = [NSAttributedStringKey.font : cell.address.font] as [NSAttributedStringKey : Any]
                        var boldString = NSMutableAttributedString(string: boldText, attributes:attrs)
                        boldString.addAttribute(NSAttributedStringKey.paragraphStyle , value: mutableParagraphStyle, range: NSMakeRange("\n\(project.state), \(project.country)".count, distance.count))
                        mutableParagraphStyle = NSMutableParagraphStyle()
                        // Customize the line spacing for paragraph.
                        mutableParagraphStyle.lineSpacing = CGFloat(30)
                        
                        boldString.addAttribute(NSAttributedStringKey.paragraphStyle , value: mutableParagraphStyle, range: NSMakeRange("\n\(project.state), \(project.country)".count, distance.count))
                        attributedString.append(boldString)
                        cell.projectname.attributedText = attributedString
                        //cell.projectname.attributedText = "\(project.title)\n\(project.address.replacingOccurrences(of: "\n", with: ""))"
                        
                        return cell
                    }
                
            }
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        return cell
    }
    
    @objc func save(){
        print("Save")
        isFavourite = !isFavourite                        
        if(!self.isFavourite){
            var temp = [Project]()
            for i in favourites{
                if(i.ID != currentProject.ID ){
                    temp.append(i)
                }
            }
            isFavourite = false
            favourites = temp
        }else{
            isFavourite = true
            print(self.currentProject.node_id)
            self.currentProject.node_id = node_id
            self.favourites.append(self.currentProject)
        }
        self.tableView.reloadData()
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: self.favourites), forKey: "favourites")        
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
