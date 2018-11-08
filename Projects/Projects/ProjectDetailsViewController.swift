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
    var items = [GalleryItem]()
    var currentProject = Project()
    var currentLocation: CLLocation?
    var maxScore = 0
    var latitude = 0.0
    var nearbyprojects = [Project]()
    var longitude = 0.0
    var currentScore = 0
    var scoreCard = [Scorecard]()
    var projectID = ""
    var Details = ProjectDetails()
    var node_id = ""
    var expandSite = false
    var expandDetails = true
    var expandScoreCard = true
    var expandNearby = true
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView.init(frame: .zero)
        tableView.separatorInset = UIEdgeInsetsMake(0, 24, 0, 24)
        print("Selected node ID is ", node_id)
        tableView.register(UINib(nibName: "ProjectCellwithImage", bundle: nil), forCellReuseIdentifier: "ProjectCellwithImage")
        tableView.register(UINib(nibName: "stackCell", bundle: nil), forCellReuseIdentifier: "stackCell")
        tableView.register(UINib(nibName: "titleCell", bundle: nil), forCellReuseIdentifier: "titleCell")
        
        tableView.register(UINib(nibName: "expandCollapseCell", bundle: nil), forCellReuseIdentifier: "expandCollapseCell")
        
        tableView.register(UINib(nibName: "OperationsCell", bundle: nil), forCellReuseIdentifier: "OperationsCell")
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
        
        
        tableView.register(UINib.init(nibName: "expandCollapse", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: "expandCollapse")
        tableView.register(UINib.init(nibName: "ScorecardCell", bundle: nil), forCellReuseIdentifier: "ScorecardCell")
        
        
        
        DispatchQueue.main.async {
            self.tableView.isHidden = true
            Utility.showLoading()
            self.tableView.isUserInteractionEnabled = false
            self.getDetails(nodeid: self.node_id)
        }        
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
            //self.tableView.reloadData()
        }
//        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.black]
//        navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = UIColor.black
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        
//        self.navigationController?.navigationBar.isTranslucent = false
//        self.navigationController?.navigationBar.barTintColor = UIColor.white
//        self.navigationController?.navigationBar.isTranslucent = false
        //self.navigationController?.navigationBar.tintColor = self.tabBarController?.tabBar.tintColor
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
//        var noofsections = 1
//        titleArray = [String]()
//        titleArray.append("")
//        if(self.Details.description_full.count > 0){
//            titleArray.append("Details")
//            noofsections = noofsections + 1
//        }
//        if(self.scoreCard.count > 0){
//            titleArray.append("Scorecard")
//            noofsections = noofsections + 1
//        }
//        if(self.nearbyprojects.count > 0){
//            titleArray.append("Projects nearby")
//            noofsections = noofsections + 1
//        }
//
//        return noofsections
        
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(titleArray[indexPath.row] == "profile_image"){
            return UIScreen.main.bounds.size.height * 0.4
        }else if(titleArray[indexPath.row] == "info"){
            return UITableViewAutomaticDimension
        }else if(titleArray[indexPath.row] == "title"){
            return UITableViewAutomaticDimension
        }else if(titleArray[indexPath.row] == "operations"){
            return UIScreen.main.bounds.size.height * 0.12
        }else if(titleArray[indexPath.row] == "certification_info" || titleArray[indexPath.row] == "registration_info"){
            return UITableViewAutomaticDimension
        }else if(titleArray[indexPath.row] == "size" || titleArray[indexPath.row] == "use" || titleArray[indexPath.row] == "setting" || titleArray[indexPath.row] == "energystar" || titleArray[indexPath.row] == "walkscore" || titleArray[indexPath.row] == "certified"){
            return UITableViewAutomaticDimension
        }else if(titleArray[indexPath.row] == "details heading"){
            return 50
        }else if(titleArray[indexPath.row] == "scorecard heading"){
            return 50
        }else if(titleArray[indexPath.row].contains("scorecard:")){
            if(expandScoreCard){
                var j = 0
                for i in 0 ..< titleArray.count {
                    var t = titleArray[i]
                    if(t.contains("scorecard:")){
                        j = j + 1
                    }
                }
                
                if(j > 0){
                    print((titleArray.index(of: "scorecard heading")! + j ))
                    if(indexPath.row == (titleArray.index(of: "scorecard heading")! + j )){
                        return 54
                    }
                }
                return UITableViewAutomaticDimension
            }else{
                return 0
            }
        }else if(titleArray[indexPath.row].contains("nearby:")){
            if(expandNearby){
                return UITableViewAutomaticDimension
            }else{
                return 0
            }
        }else if(titleArray[indexPath.row] == "nearby heading"){
            return UITableViewAutomaticDimension
        }else if(titleArray[indexPath.row] == "details"){
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
 
        return UIScreen.main.bounds.size.height * 0.05
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
            let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "expandCollapse") as! expandCollapse
            cell.contentView.frame.origin.x = 24
            cell.contentView.frame.size.width -= 2 * 24
            //let cell = tableView.dequeueReusableCell(withIdentifier: "expandCollapseCell") as! expandCollapseCell
            cell.tag = 10 + section
            cell.addTapGesture(tapNumber: 1, target: self, action: #selector(headerTapped(view:)))
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
            cell.layoutIfNeeded()
            return cell
        }        
        return tableView.headerView(forSection: section)
    }
    
    @objc func headerTapped(view : UITapGestureRecognizer){
        print(view.view!.tag)
        var scroll = false
        if(titleArray[view.view!.tag - 10] == "details heading"){
            expandDetails = !expandDetails
            tableView.reloadRows(at: [IndexPath.init(row: view.view!.tag - 10, section: 0)], with: .fade )
        }else if(titleArray[view.view!.tag - 10] == "scorecard heading"){
            expandScoreCard = !expandScoreCard
            if(!expandScoreCard){
                scroll = true
            }
            var arr = [IndexPath]()
            for i in 0 ..< titleArray.count {
                var t = titleArray[i]
                if(t.contains("scorecard")){
                    arr.append(IndexPath.init(row: i, section: 0))
                }
            }
            if(arr.count > 0){
                tableView.reloadRows(at: arr, with: .fade )
            }
        }else if(titleArray[view.view!.tag - 10] == "nearby heading"){
            expandNearby = !expandNearby
            if(!expandNearby){
                scroll = true
            }
            var arr = [IndexPath]()
            for i in 0 ..< titleArray.count {
                var t = titleArray[i]
                if(t.contains("nearby")){
                    arr.append(IndexPath.init(row: i, section: 0))
                }
            }
            if(arr.count > 0){
                tableView.reloadRows(at: arr, with: .fade )
            }
        }
        
        //self.tableView.reloadSections(IndexSet(integersIn: view.view!.tag - 10...view.view!.tag - 10), with: UITableViewRowAnimation.fade)
    }
    
    @objc func expandCollapse(button : UIButton){
        print(button.tag)
        var scroll = false
        print(button.tag)
        if(titleArray[button.tag] == "details heading"){
            expandDetails = !expandDetails
            if(!expandDetails){
                scroll = true
            }
            tableView.reloadRows(at: [IndexPath.init(row: button.tag, section: 0)], with: .fade )
        }else if(titleArray[button.tag] == "scorecard heading"){
            expandScoreCard = !expandScoreCard
            if(!expandScoreCard){
                scroll = true
            }
            var arr = [IndexPath]()
            for i in 0 ..< titleArray.count {
                var t = titleArray[i]
                if(t.contains("scorecard")){
                    arr.append(IndexPath.init(row: i, section: 0))
                }
            }
            if(arr.count > 0){
                tableView.reloadRows(at: arr, with: .fade )
            }
        }else if(titleArray[button.tag] == "nearby heading"){
            expandNearby = !expandNearby
            if(!expandNearby){
                scroll = true
            }
            var arr = [IndexPath]()
            for i in 0 ..< titleArray.count {
                var t = titleArray[i]
                if(t.contains("nearby")){
                    arr.append(IndexPath.init(row: i, section: 0))
                }
            }
            if(arr.count > 0){
                tableView.reloadRows(at: arr, with: .fade )
            }
        }
        //tableView.reloadData()
        if(scroll == true){
            //tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
        }
        //tableView.scrollToRow(at: IndexPath.init(row: 0, section: button.tag), at: .top, animated: true)
        print(button.tag)
        //self.tableView.reloadSections(IndexSet(integersIn: button.tag...button.tag), with: UITableViewRowAnimation.fade)
        
    }
        
        
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        return ""
    }
    
    func getProjectScorecard(projectID : String){
        Apimanager.shared.getProjectScorecard(id: projectID, callback:  { (scorecards, code) in
            DispatchQueue.main.async {
                self.maxScore = 0
                self.currentScore = 0
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
                    self.scoreCard = scoreCards
                }
                
                for i in self.scoreCard{
                    self.currentScore = self.currentScore + Int(i.awarded)!
                    self.maxScore = self.maxScore + Int(i.possible)!
                }                
                self.getNearbyProjects()
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
                temp.removeAll()
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
                    self.maxScore = self.maxScore + Int(i.possible)!
                }
                self.tableView.reloadData()
                self.getNearbyProjects()
            }
            }
        })
    }
    
    func getDetails(nodeid : String){
        print("Node id is ", nodeid)
        Apimanager.shared.getProjectDetails(id: nodeid, callback: {(projectDetails, code) in
            if(code == -1 && projectDetails != nil){
                    //self.totalCount = totalCount!
                DispatchQueue.main.async {
                    let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
                    label.backgroundColor = .clear
                    label.numberOfLines = 0
                    label.textAlignment = .center
                    label.font = UIFont.AktivGrotesk_Md(size: 15)
                    label.text = self.currentProject.title
                    self.navigationItem.titleView = label
                    print(self.currentProject.lat)
                    print(self.currentProject.long)
                    self.currentLocation = CLLocation.init(latitude: Double(self.currentProject.lat)!, longitude: Double(self.currentProject.long)!)
                    self.Details = projectDetails!
                    self.latitude = CLLocationDegrees(self.Details.lat)!
                    self.longitude = CLLocationDegrees(self.Details.long)!
//                    if(self.Details.project_images.count == 0){
//                        self.navigationController?.navigationBar.tintColor = UIColor.black
//                    }else{
//                        self.navigationController?.navigationBar.tintColor = UIColor.white
//                    }
                    self.Details.address = self.Details.address.replacingOccurrences(of: "\n", with: "")
                    print(self.Details.image)
                    if(self.Details.image.count > 0 && self.Details.image.range(of: "placeholder") == nil){
                        self.items.append(GalleryItem.image { callback in
                            var url = URL.init(string: self.Details.image)
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
                    self.tableView.isHidden = false
                    self.tableView.reloadData()
                    self.getProjectScorecard(projectID: self.Details.project_id)
                }
                
            }else{
                if(code == 401){
                    
                }else if(code != -999 && code != nil && code != 0){
                    Utility.hideLoading()
                    if(self.navigationController != nil){
                        //Utility.showToast(y: self.navigationController!.navigationBar.frame.size.height, message: "Something went wrong")
                    }
                }
            }
        })
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated  {
            print(navigationAction.request.url?.absoluteString)
            if let url = navigationAction.request.url,
                let host = url.host, UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                print(url)
                print("Redirected to browser. No need to open it locally")
                decisionHandler(.cancel)
            } else {
                print("Open it locally")
                decisionHandler(.allow)
            }
        } else {
            print("not a user click")
            decisionHandler(.allow)
        }
    }
    
    func getNearbyProjects(){
        var dict = [[String : Any]]()
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
                    //self.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .bottom , animated: false)                    
                    self.tableView.reloadData()
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                    self.tableView.isHidden = false
                    Utility.hideLoading()
                    self.tableView.isUserInteractionEnabled = true
                    self.tableView.layoutIfNeeded()
                }
            }else{
                if(code == 401){
                    
                }else if(code != -999 && code != nil && code != 0 && code != 200){
                    DispatchQueue.main.async {
                        Utility.hideLoading()
                    }
                    if(self.navigationController != nil){
                        //Utility.showToast(y: self.navigationController!.navigationBar.frame.size.height, message: "Something went wrong")
                    }
                }
                
            }
        })
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in (self.navigationController?.navigationBar.subviews)! {
            view.layoutMargins = UIEdgeInsets.zero
        }
        //tabbar.invalidateIntrinsicContentSize()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        if(self.titleArray[indexPath.row] == "profile_image"){
            var gallery = GalleryViewController(startIndex: 0, itemsDataSource: self)
            gallery.toolbarItems = nil
            self.presentImageGallery(gallery)
        }else if(titleArray[indexPath.row].contains("nearby:")){
            DispatchQueue.main.async {
                self.tableView.isHidden = true
                self.items.removeAll()
                self.currentScore = 0
                self.maxScore = 0
                self.expandDetails = true
                self.expandNearby = true
                self.expandScoreCard = true
                let i = Int(self.titleArray[indexPath.row].components(separatedBy: ":")[1])!
                self.node_id = self.nearbyprojects[i].node_id
                self.currentProject = self.nearbyprojects[i]
                self.nearbyprojects.removeAll()
                Utility.showLoading()
                self.tableView.isUserInteractionEnabled = false
                self.titleArray.removeAll()
                self.tableView.reloadData()
                if(UserDefaults.standard.object(forKey: "favourites") != nil){
                    self.favourites = NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "favourites") as! Data) as! [Project]
                    self.isFavourite = false
                    for i in self.favourites{
                        if(i.ID == self.currentProject.ID){
                            self.isFavourite = true
                            break
                        }
                        print(i.title)
                    }
                    //self.tableView.reloadData()
                }
                self.getDetails(nodeid: self.node_id)
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
                    let currentrow = self.titleArray.index(of: "details")
                    self.tableView.reloadRows(at: [IndexPath(row: currentrow!, section: 0)], with: .automatic)
                })
            }
            
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var temp = [String]()
        if(self.Details.project_id == ""){
            return 0
        }
        if(self.Details.image.count > 0 && self.Details.image.range(of: "placeholder") == nil){
                temp.append("profile_image")
        }
        temp.append("info")
        temp.append("operations")
        if(self.Details.certification_date.count > 0){
            temp.append("certification_info")
        }else{
            temp.append("registration_info")
        
        }
        
        if(self.Details.project_size != ""){
            temp.append("size")
        }
        
        if(self.Details.project_type != ""){
            temp.append("use")
        }
        if(self.Details.project_setting != ""){
            temp.append("setting")
        }
        
        if(self.Details.certification_date != ""){
            temp.append("certified")
        }
        
        if(self.Details.project_walkscore != ""){
            temp.append("walkscore")
        }
        
        if(self.Details.energy_star_score != ""){
            temp.append("energystar")
        }
        
        
        
        if(self.Details.description_full.count > 0){
                temp.append("details heading")
                temp.append("details")
        }
        if(self.scoreCard.count > 0){
            temp.append("scorecard heading")
            for i in 0 ..< self.scoreCard.count{
                temp.append("scorecard:\(i)")
            }
        }
        if(self.nearbyprojects.count > 0){
            temp.append("nearby heading")
            for i in 0 ..< self.nearbyprojects.count{
                temp.append("nearby:\(i)")
            }
        }
        titleArray = temp
        print(temp)
        return titleArray.count
  
    }
    
    func nobr(_ string:String) -> String {
        var s = string
        print(s)
        s = s.replacingOccurrences(of: " ", with: "\u{00a0}")
        s = s.replacingOccurrences(of: "-", with: "\u{2011}")
        print(s)
        
        return s
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(titleArray[indexPath.row] == "size"){
            let stackCell = tableView.dequeueReusableCell(withIdentifier: "stackCell") as! stackCell
            stackCell.lbl.text = "Size"
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            var formattedNumber = ""
            formattedNumber = numberFormatter.string(from: NSNumber(value:Int(self.Details.project_size)!))!
            stackCell.detaillbl.text = "\(formattedNumber) sf"
            stackCell.separatorInset = UIEdgeInsetsMake(0, -18, 0, UIScreen.main.bounds.width)
            return stackCell
        }else if(titleArray[indexPath.row] == "certified"){
            let stackCell = tableView.dequeueReusableCell(withIdentifier: "stackCell") as! stackCell
            stackCell.lbl.text = "Certified on"
            var dateFormat = DateFormatter()
            dateFormat.dateFormat = "MM/dd/yyyy"
            var date = Date()
            date = dateFormat.date(from: self.Details.certification_date)!
            dateFormat.dateFormat = "yyyy"
            var justyear = dateFormat.string(from: date)
            dateFormat.dateFormat = "MMM dd, yyyy"
            stackCell.detaillbl.text = "\(dateFormat.string(from: date))"
            stackCell.separatorInset = UIEdgeInsetsMake(0, -18, 0, UIScreen.main.bounds.width)
            return stackCell
        }else if(titleArray[indexPath.row] == "use"){
            let stackCell = tableView.dequeueReusableCell(withIdentifier: "stackCell") as! stackCell
            stackCell.lbl.text = "Use"
            stackCell.detaillbl.text = "\(self.Details.project_type)"
            stackCell.separatorInset = UIEdgeInsetsMake(0, -18, 0, UIScreen.main.bounds.width)
            return stackCell
        }else if(titleArray[indexPath.row] == "setting"){
            let stackCell = tableView.dequeueReusableCell(withIdentifier: "stackCell") as! stackCell
            stackCell.lbl.text = "Setting"
            stackCell.detaillbl.text = "\(self.Details.project_setting)"
            stackCell.separatorInset = UIEdgeInsetsMake(0, -18, 0, UIScreen.main.bounds.width)
            return stackCell
        }else if(titleArray[indexPath.row] == "walkscore"){
            let stackCell = tableView.dequeueReusableCell(withIdentifier: "stackCell") as! stackCell
            stackCell.lbl.text = "Walk Score®"
            stackCell.detaillbl.text = "\(self.Details.project_walkscore)"
            stackCell.separatorInset = UIEdgeInsetsMake(0, -18, 0, UIScreen.main.bounds.width)
            return stackCell
        }else if(titleArray[indexPath.row] == "energystar"){
            let stackCell = tableView.dequeueReusableCell(withIdentifier: "stackCell") as! stackCell
            stackCell.lbl.text = "Energy star score®"
            stackCell.detaillbl.text = "\(self.Details.energy_star_score)"
            stackCell.separatorInset = UIEdgeInsetsMake(0, -18, 0, UIScreen.main.bounds.width)
            return stackCell
        }else if(titleArray[indexPath.row] == "profile_image"){
            let thumbnailView = tableView.dequeueReusableCell(withIdentifier: "thumbnail", for: indexPath) as! thumbnail
                                thumbnailView.selectionStyle = .none
                                if(self.Details.image.count > 0 && self.Details.image.range(of: "placeholder") == nil){
                                    print(self.Details.image)
                                    
                                    thumbnailView.imgView.image = nil
                                    var url = URL.init(string: self.Details.image)
                                    let remoteImageURL = url
                                    if(url != nil){
                                        Alamofire.request(remoteImageURL!).responseData { (response) in
                                            if response.error == nil {
                                                if let data = response.data {
                                                    thumbnailView.imgView.image = UIImage(data: data)
                                                }
                                            }else{
                                                
                                            }
                                        }
                                    }
                                    
                                //thumbnailView.imgView.sd_setImage(with: URL(string: self.Details.image), placeholderImage: UIImage.init(named: "project_placeholder"))
                                }else{
                                    thumbnailView.imgView.image = UIImage.init(named: "project_placeholder")
                                }
                                thumbnailView.thumbnailcount.text = "\(self.Details.project_images.count + 1)"
            
                                thumbnailView.selectionStyle = .none
                                return thumbnailView
        }
        
        
        if(titleArray[indexPath.row] == "title"){
            let titleView = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! titleCell
            titleView.title.text = "\(self.Details.title)"
            return titleView
        }
        
        if(titleArray[indexPath.row] == "info"){
            let projectInfoView = tableView.dequeueReusableCell(withIdentifier: "projectInfo", for: indexPath) as! projectInfo
            let style = NSMutableParagraphStyle()
            style.lineBreakMode = .byWordWrapping
            
            //projectInfoView.name.text = self.Details.title
            self.Details.title = self.Details.title.replacingOccurrences(of: "\n", with: ", ")
            self.Details.title = self.Details.title.replacingOccurrences(of: "\u{00A0}", with: "\u{0020}")
            self.Details.address = self.Details.address.replacingOccurrences(of: "\n", with: ", ")
            
            
            var t = ""
            if(self.Details.city.count > 0 && self.Details.state.count > 0 && self.Details.zip_code.count > 0){
                t = t + self.Details.city + ", \(self.Details.state), \(self.Details.zip_code)\n"
            }
            
            if(self.Details.state.count > 0){
                //t = t + self.Details.state + ",\n"
            }
            
            if(self.Details.country.count > 0){
                t = t + self.Details.country
            }
            
            if(t[t.index(before: t.endIndex)] != "\n"){
                t = String(t.prefix(t.count))
            }else{
                t = String(t.prefix(t.count - 2))
            }
            
            var attr = NSMutableAttributedString.init(string: "")
            let attributed = NSMutableAttributedString.init(string: "\(Details.title)\n\(self.Details.address),\n\(t)")
            
            attributed.addAttributes([NSAttributedStringKey.foregroundColor: UIColor(red:0.16, green:0.2, blue:0.23, alpha:1), NSAttributedStringKey.font : UIFont.AktivGrotesk_Rg(size: 14) ], range: NSMakeRange("\(Details.title)".count, "\n\(self.Details.address),\n\(t)".count ))
            
            attr.append(attributed)
//            projectInfoView.name.minimumScaleFactor = 0.9
//            projectInfoView.name.sizeToFit()
//            projectInfoView.name.adjustsFontSizeToFitWidth = true
            projectInfoView.name.attributedText = attr
            projectInfoView.selectionStyle = .none
            projectInfoView.selectionStyle = .none
            return projectInfoView
        }
        if(titleArray[indexPath.row] == "operations"){
            let OperationsCellView = tableView.dequeueReusableCell(withIdentifier: "OperationsCell", for: indexPath) as! OperationsCell
            if(isFavourite == false){
                OperationsCellView.saveImage.image = UIImage.init(named: "Favorites_BU")
                OperationsCellView.saveLbl.text = "Save"
                let tintedImage = OperationsCellView.saveImage.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                OperationsCellView.saveImage.image = tintedImage
                OperationsCellView.saveImage.tintColor = UIColor(red:0.35, green:0.41, blue:0.45, alpha:1)
            }else{
                OperationsCellView.saveImage.image = UIImage.init(named: "Favorites_Active_BU")
                OperationsCellView.saveLbl.text = "Saved"
                let tintedImage = OperationsCellView.saveImage.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                OperationsCellView.saveImage.image = tintedImage
                OperationsCellView.saveImage.tintColor = UIColor(red:0.35, green:0.41, blue:0.45, alpha:1)
            }
            
            
            OperationsCellView.saveView.addTapGesture(tapNumber: 1, target: self, action: #selector(save))
            OperationsCellView.directionsView.addTapGesture(tapNumber: 1, target: self, action: #selector(direction))
            OperationsCellView.shareView.addTapGesture(tapNumber: 1, target: self, action: #selector(share))
            OperationsCellView.selectionStyle = .none
            OperationsCellView.selectionStyle = .none
            return OperationsCellView
        }
        if(titleArray[indexPath.row] == "certification_info"){
            let CertificationInfoView = tableView.dequeueReusableCell(withIdentifier: "CertificationInfo", for: indexPath) as! CertificationInfo
            CertificationInfoView.selectionStyle = .none
            CertificationInfoView.separatorInset = UIEdgeInsetsMake(0, -18, 0, UIScreen.main.bounds.width)
            var justyear = ""
                        if(self.Details.project_certification_level.replacingOccurrences(of: " ", with: "").count == 0){
                            self.Details.project_certification_level = "NONE"
                        }
            let tempLevel = "\n\(self.Details.project_certification_level.uppercased())"
            let tempscore = "\n\(self.currentScore)"
            let tempmaxscore = "/\(self.maxScore)"
            let temprating = "\n\(self.Details.project_rating_system) - \(self.Details.project_rating_system_version)"
            var s = ""
            if(self.currentScore > 0 && self.maxScore > 0){
                s = "CERTIFICATION \(tempLevel)\(tempscore)\(tempmaxscore)\(temprating)"
            }else{
                s = "CERTIFICATION \(tempLevel)\(temprating)"
            }
            var cert_color = UIColor()
            if(self.Details.project_certification_level.lowercased() == "certified"){
                cert_color = UIColor(red:76/255, green:175/255, blue:85/255, alpha:1.0)
            }else if(self.Details.project_certification_level.lowercased() == "gold"){
                cert_color = UIColor(red:198/255, green:162/255, blue:0/255, alpha:1.0)
            }else if(self.Details.project_certification_level.lowercased() == "platinum"){
                cert_color = UIColor(red:77/255, green:77/255, blue:77/255, alpha:1.0)
            }else if(self.Details.project_certification_level.lowercased() == "silver"){
                cert_color = UIColor(red:110/255, green:130/255, blue:142/255, alpha:1.0)
            }else if(self.Details.project_certification_level.lowercased() == ""){
                cert_color = UIColor(red:21/255, green:101/255, blue:192/255, alpha:1.0)
            }
            
            var string = NSMutableAttributedString(string: s)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 3
            string.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, s.count))
            
            string.addAttribute(NSAttributedStringKey.font, value: UIFont.AktivGrotesk_Md(size: 12), range: NSMakeRange(0, "CERTIFICATION".count))
            
            string.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(red:0.35, green:0.41, blue:0.45, alpha:1), range: NSMakeRange(0, "CERTIFICATION ".count))
            
            string.addAttribute(NSAttributedStringKey.font, value: UIFont.AktivGrotesk_Md(size: 16), range: NSMakeRange("CERTIFICATION ".count, "\(tempLevel)".count))
            string.addAttribute(NSAttributedStringKey.foregroundColor, value: cert_color, range: NSMakeRange("CERTIFICATION ".count, "\(tempLevel)".count))
            
            string.addAttribute(NSAttributedStringKey.font, value: UIFont.AktivGrotesk_Md(size: 16), range: NSMakeRange("CERTIFICATION \(tempLevel)".count, "\(tempscore)".count))
            string.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.black, range: NSMakeRange("CERTIFICATION \(tempLevel)".count, "\(tempscore)".count))
            
            if(self.currentScore > 0 && self.maxScore > 0){
            string.addAttribute(NSAttributedStringKey.font, value: UIFont.AktivGrotesk_Md(size: 16), range: NSMakeRange("CERTIFICATION \n\(self.Details.project_certification_level.uppercased())\n\(self.currentScore)".count, "/\(self.maxScore)".count))
            string.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(red:0.53, green:0.6, blue:0.64, alpha:1), range: NSMakeRange("CERTIFICATION \n\(self.Details.project_certification_level.uppercased())\n\(self.currentScore)".count, "/\(self.maxScore)".count))
            
            string.addAttribute(NSAttributedStringKey.font, value: UIFont.AktivGrotesk_Md(size: 16), range: NSMakeRange("CERTIFICATION \n\(self.Details.project_certification_level.uppercased())\n\(self.currentScore)/\(self.maxScore)\n".count, "\(self.Details.project_rating_system) - \(self.Details.project_rating_system_version)".count))
            string.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(red:0.16, green:0.2, blue:0.23, alpha:1), range: NSMakeRange("CERTIFICATION \n\(self.Details.project_certification_level.uppercased())\n\(self.currentScore)/\(self.maxScore)\n".count, "\(self.Details.project_rating_system) - \(self.Details.project_rating_system_version)".count))
            }else{
                string.addAttribute(NSAttributedStringKey.font, value: UIFont.AktivGrotesk_Md(size: 16), range: NSMakeRange("CERTIFICATION \n\(self.Details.project_certification_level.uppercased())\n".count, "\(self.Details.project_rating_system) - \(self.Details.project_rating_system_version)".count))
                string.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(red:0.16, green:0.2, blue:0.23, alpha:1), range: NSMakeRange("CERTIFICATION \n\(self.Details.project_certification_level.uppercased())\n".count, "\(self.Details.project_rating_system) - \(self.Details.project_rating_system_version)".count))
            }
            
            CertificationInfoView.data.attributedText = string

            if(currentScore > 0 && maxScore > 0){
                var attr = NSMutableAttributedString.init(string: "\(currentScore)")
                let attributed = NSMutableAttributedString.init(string: "/\(maxScore)")
            }else{
                var attr = NSMutableAttributedString.init(string: "\(self.Details.project_rating_system) - \(self.Details.project_rating_system_version)")
                let t = "\(self.Details.project_rating_system) - \(self.Details.project_rating_system_version)"
                let attributed = NSMutableAttributedString.init(string: t)
                attributed.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.blue], range: NSMakeRange(0, "/\(t)".count-1))
                //CertificationInfoView.certification_score.attributedText = attributed
                
            }

            CertificationInfoView.selectionStyle = .none
            return CertificationInfoView
        }
        
        if(titleArray[indexPath.row] == "registration_info"){
            let CertificationInfoView = tableView.dequeueReusableCell(withIdentifier: "CertificationInfo", for: indexPath) as! CertificationInfo
            CertificationInfoView.selectionStyle = .none
            CertificationInfoView.separatorInset = UIEdgeInsetsMake(0, -18, 0, UIScreen.main.bounds.width)
            var justyear = ""
            if(self.Details.project_certification_level.replacingOccurrences(of: " ", with: "").count == 0){
                self.Details.project_certification_level = "NONE"
            }
            let tempLevel = "\nREGISTERED"
            let tempscore = "\n\(self.currentScore)"
            let tempmaxscore = "/\(self.maxScore)"
            let temprating = "\n\(self.Details.project_rating_system) - \(self.Details.project_rating_system_version)"
            var s = ""
            if(self.currentScore > 0 && self.maxScore > 0){
                s = "REGISTERED \(tempLevel)\(tempscore)\(tempmaxscore)\(temprating)"
            }else{
                s = "REGISTERED \(temprating)"
            }
            var string = NSMutableAttributedString(string: s)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 3
            string.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, s.count))
            
            string.addAttribute(NSAttributedStringKey.font, value: UIFont.AktivGrotesk_Md(size: 12), range: NSMakeRange(0, "REGISTERED".count))
            
            string.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(red:0.35, green:0.41, blue:0.45, alpha:1), range: NSMakeRange(0, "REGISTERED".count))
            
            string.addAttribute(NSAttributedStringKey.font, value: UIFont.AktivGrotesk_Rg(size: 14), range: NSMakeRange("REGISTERED ".count, "\(temprating)".count))
            string.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(red:0.16, green:0.2, blue:0.23, alpha:1), range: NSMakeRange("REGISTERED ".count, "\(temprating)".count))
            
            CertificationInfoView.data.attributedText = string
            
                var attr = NSMutableAttributedString.init(string: "\(self.Details.project_rating_system) - \(self.Details.project_rating_system_version)")
                let t = "\(self.Details.project_rating_system) - \(self.Details.project_rating_system_version)"
                let attributed = NSMutableAttributedString.init(string: t)
                attributed.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.blue], range: NSMakeRange(0, "/\(t)".count-1))
                //CertificationInfoView.certification_score.attributedText = attributed
            
            
            CertificationInfoView.selectionStyle = .none
            return CertificationInfoView
        }
        
        if(titleArray[indexPath.row] == "details heading"){
            let cell = tableView.dequeueReusableCell(withIdentifier: "expandCollapseCell", for: indexPath) as! expandCollapseCell
            
            cell.tag = 10 + indexPath.row
            cell.addTapGesture(tapNumber: 1, target: self, action: #selector(headerTapped(view:)))
            cell.expandButton.tag = indexPath.row
            var temp = false
            if(expandDetails){
                cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, UIScreen.main.bounds.width)
            }else{
                cell.separatorInset = UIEdgeInsetsMake(0, 24, 0, 24)
            }

            cell.title.text = "Details"
            if(expandDetails){
                cell.expandButton.setImage(UIImage.init(named: "arrow_down"), for: .normal)
            }else{
                cell.expandButton.setImage(UIImage.init(named: "arrow_right"), for: .normal)
            }
            let tintedImage = cell.expandButton.imageView?.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            cell.expandButton.setImage(tintedImage, for: .normal)
            cell.expandButton.tintColor = UIColor(red:0.53, green:0.60, blue:0.64, alpha:1.0)
            
            cell.expandButton.addTarget(self, action: #selector(expandCollapse(button:)), for: .touchUpInside)
            cell.layoutIfNeeded()
            cell.selectionStyle = .none
            return cell
        }
        
        if(titleArray[indexPath.row] == "details"){
            let AboutprojectView = tableView.dequeueReusableCell(withIdentifier: "Aboutproject", for: indexPath) as! Aboutproject
            
                AboutprojectView.separatorInset = UIEdgeInsetsMake(0, -18, 0, UIScreen.main.bounds.width)
            
                                AboutprojectView.selectionStyle = .none
                                print(self.Details.description_full)
            AboutprojectView.webview.loadHTMLString("<html><head><meta name='viewport' content='initial-scale=1.0, user-scalable=no, width=device-width, viewport-fit=cover'/><style> a {color : #1677BA;} p {line-height: 1.5;}</style></head><body style=\"font-family: 'HelveticaNeue'; color : #28323B\">\(self.Details.description_full)</body></html>", baseURL: nil)
                                AboutprojectView.webview.tag = 70 + indexPath.section
                                AboutprojectView.webview.scrollView.layer.masksToBounds = false
                                AboutprojectView.webview.navigationDelegate = self
            AboutprojectView.selectionStyle = .none
                                return AboutprojectView
        }
        
        if(titleArray[indexPath.row] == "scorecard heading"){
            let cell = tableView.dequeueReusableCell(withIdentifier: "expandCollapseCell", for: indexPath) as! expandCollapseCell
            if(expandScoreCard){
                cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, UIScreen.main.bounds.width)
            }else{
                cell.separatorInset = UIEdgeInsetsMake(0, 24, 0, 24)
            }
            
            cell.tag = 10 + indexPath.row
            cell.addTapGesture(tapNumber: 1, target: self, action: #selector(headerTapped(view:)))
            cell.expandButton.tag = indexPath.row
            var temp = false
            
            
            cell.title.text = "Scorecard"
            if(expandScoreCard){
                cell.expandButton.setImage(UIImage.init(named: "arrow_down"), for: .normal)
            }else{
                cell.expandButton.setImage(UIImage.init(named: "arrow_right"), for: .normal)
            }
            let tintedImage = cell.expandButton.imageView?.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            cell.expandButton.setImage(tintedImage, for: .normal)
            cell.expandButton.tintColor = UIColor(red:0.53, green:0.60, blue:0.64, alpha:1.0)
            cell.expandButton.addTarget(self, action: #selector(expandCollapse(button:)), for: .touchUpInside)
            cell.layoutIfNeeded()
            cell.selectionStyle = .none
            return cell
        }
        
        if(titleArray[indexPath.row].contains("scorecard:")){
            let i = Int(titleArray[indexPath.row].components(separatedBy: ":")[1])!
            let scorecardcellView = tableView.dequeueReusableCell(withIdentifier: "ScorecardCell", for: indexPath) as! ScorecardCell
            
            var j = 0
            for i in 0 ..< titleArray.count {
                var t = titleArray[i]
                if(t.contains("scorecard:")){
                    j = j + 1
                }
            }
            scorecardcellView.separatorInset = UIEdgeInsetsMake(0, 6, 0, 6)
            if(j > 0){
                print((titleArray.index(of: "scorecard heading")! + j ))
                if(indexPath.row == (titleArray.index(of: "scorecard heading")! + j )){
                    scorecardcellView.separatorInset = UIEdgeInsetsMake(0, -48, 0, UIScreen.main.bounds.width)
                }
            }
            
            
            if(expandScoreCard){
                scorecardcellView.contentView.isHidden = false
            }else{
                scorecardcellView.contentView.isHidden = true
            }
            scorecardcellView.titleLabel.text = "\(self.scoreCard[i].name)"
            var attr = NSMutableAttributedString.init(string: "\(scoreCard[i].awarded)")
            let attributed = NSMutableAttributedString.init(string: "/\(scoreCard[i].possible)")
            attributed.addAttributes([NSAttributedStringKey.foregroundColor: scorecardcellView.maxscoreLabel.textColor], range: NSMakeRange(0, "/\(scoreCard[i].possible)".count ))
            
            attr.append(attributed)
            
            scorecardcellView.scoreLabel.attributedText = attr
            //scorecardcellView.maxscoreLabel.text = "/\(scoreCard[indexPath.row].possible)"
            scorecardcellView.scoreImageView.image = UIImage(named: scoreCard[i].getImage())
            scorecardcellView.selectionStyle = .none
            scorecardcellView.selectionStyle = .none
            return scorecardcellView

        }
        
        if(titleArray[indexPath.row] == "nearby heading"){
            let cell = tableView.dequeueReusableCell(withIdentifier: "expandCollapseCell", for: indexPath) as! expandCollapseCell
            if(expandNearby){
                cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, UIScreen.main.bounds.width)
            }else{
                cell.separatorInset = UIEdgeInsetsMake(0, 24, 0, 24)
            }
            cell.tag = 10 + indexPath.row
            cell.addTapGesture(tapNumber: 1, target: self, action: #selector(headerTapped(view:)))
            cell.expandButton.tag = indexPath.row
            var temp = false
            
            cell.title.text = "Projects Nearby"
            if(expandNearby){
                cell.expandButton.setImage(UIImage.init(named: "arrow_down"), for: .normal)
            }else{
                cell.expandButton.setImage(UIImage.init(named: "arrow_right"), for: .normal)
            }
            
            let tintedImage = cell.expandButton.imageView?.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            cell.expandButton.setImage(tintedImage, for: .normal)
            cell.expandButton.tintColor = UIColor(red:0.53, green:0.60, blue:0.64, alpha:1.0)
            cell.expandButton.addTarget(self, action: #selector(expandCollapse(button:)), for: .touchUpInside)
            cell.layoutIfNeeded()
            cell.selectionStyle = .none
            return cell
        }
        
        if(titleArray[indexPath.row].contains("nearby:")){
            let i = Int(titleArray[indexPath.row].components(separatedBy: ":")[1])!
            let project = nearbyprojects[i]
                                var tempLocation = currentLocation
                                if(project.lat != "" && project.long != ""){
                                    tempLocation = CLLocation.init(latitude: Double(project.lat)!, longitude: Double(project.long)!)
                                }
            if(project.image.count > 0 && !project.image.contains("project_placeholder")){
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCellwithImage") as! ProjectCellwithImage
                //cell.projectname.text = "\(project.title)"
                let normalText  = "\(project.title)"
                let attributedString = NSMutableAttributedString(string:normalText)
                var distance = ""
                if((tempLocation?.distance(from: currentLocation!))!/1609.34 < 1000){
                    distance = "\(Double(round((tempLocation?.distance(from: currentLocation!))!/1609.34 * 100)/100)) m. away"
                }else{
                    distance = "1000+ mi. away"
                }
                var boldText = "\n\(project.state), \(project.country)\n\(project.certification_level.capitalized) • \(distance)"
                var mutableParagraphStyle = NSMutableParagraphStyle()
                
                // *** set LineSpacing property in points ***
                mutableParagraphStyle.lineSpacing = 4 // Whatever line spacing you want in points
                //bold.addAttribute(NSAttributedStringKey.paragraphStyle , value: mutableParagraphStyle, range: NSMakeRange(0, boldText.count))
                
                if(expandNearby){
                    cell.contentView.isHidden = false
                }else{
                    cell.contentView.isHidden = true
                }
                cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 14)
                
                var cert_color = UIColor()
                if(project.certification_level.lowercased() == "certified"){
                    cert_color = UIColor(red:76/255, green:175/255, blue:85/255, alpha:1.0)
                    boldText = "\n\(project.state), \(project.country)\n\(project.certification_level.capitalized) • \(distance)"
                }else if(project.certification_level.lowercased() == "gold"){
                    cert_color = UIColor(red:198/255, green:162/255, blue:0/255, alpha:1.0)
                    boldText = "\n\(project.state), \(project.country)\n\(project.certification_level.capitalized) • \(distance)"
                }else if(project.certification_level.lowercased() == "platinum"){
                    cert_color = UIColor(red:77/255, green:77/255, blue:77/255, alpha:1.0)
                    boldText = "\n\(project.state), \(project.country)\n\(project.certification_level.capitalized) • \(distance)"
                }else if(project.certification_level.lowercased() == "silver"){
                    cert_color = UIColor(red:110/255, green:130/255, blue:142/255, alpha:1.0)
                    boldText = "\n\(project.state), \(project.country)\n\(project.certification_level.capitalized) • \(distance)"
                }else {
                    cert_color = UIColor(red:21/255, green:101/255, blue:192/255, alpha:1.0)
                    boldText = "\n\(project.state), \(project.country)\n\(distance)"
                }
                let attrs = [NSAttributedStringKey.font : cell.address.font] as [NSAttributedStringKey : Any]
                var boldString = NSMutableAttributedString(string: boldText, attributes:attrs)
                boldString.addAttribute(NSAttributedStringKey.paragraphStyle , value: mutableParagraphStyle, range: NSMakeRange(0, boldText.count))
                
                if(project.certification_level.lowercased() == "certified" || project.certification_level.lowercased() == "gold" || project.certification_level.lowercased() == "platinum" || project.certification_level.lowercased() == "silver"){
                    boldString.addAttribute(NSAttributedStringKey.foregroundColor , value: cert_color, range: NSMakeRange("\n\(project.state), \(project.country)\n".count, "\(project.certification_level)".count))
                    
                    boldString.addAttribute(NSAttributedStringKey.font , value: UIFont.AktivGrotesk_Md(size: 14), range: NSMakeRange("\n\(project.state), \(project.country)\n".count, "\(project.certification_level)".count))
                    
                    boldString.addAttribute(NSAttributedStringKey.foregroundColor , value: UIColor(red:0.53, green:0.60, blue:0.64, alpha:1.0), range: NSMakeRange("\n\(project.state), \(project.country)\n\(project.certification_level.uppercased()) • ".count, distance.count))
                }else{
                    boldString.addAttribute(NSAttributedStringKey.foregroundColor , value: UIColor(red:0.53, green:0.60, blue:0.64, alpha:1.0), range: NSMakeRange("\n\(project.state), \(project.country)\n".count, distance.count))
                }
                attributedString.append(boldString)
                cell.projectname.attributedText = attributedString
                //cell.address.text = "\(project.address.replacingOccurrences(of: "\n", with: ""))"
                cell.project_image.center.y = cell.contentView.frame.size.height/2
                
                var url = URL.init(string: project.image)
                let remoteImageURL = url
                if(url != nil){
                    Alamofire.request(remoteImageURL!).responseData { (response) in
                        if response.error == nil {
                            if let data = response.data {
                                cell.project_image.image = UIImage(data: data)
                            }
                        }else{
                            
                        }
                    }
                }
                cell.projectname.preferredMaxLayoutWidth = 200
                
                //cell.project_image.sd_setImage(with: URL(string: project.image), placeholderImage: UIImage.init(named: "project_placeholder"))
                
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCellwithoutImage") as! ProjectCellwithoutImage
                //cell.address.text = "\(project.address.replacingOccurrences(of: "\n", with: ""))"
                let normalText  = "\(project.title)"
                
                let attributedString = NSMutableAttributedString(string:normalText)
                var distance = ""
                if((tempLocation?.distance(from: currentLocation!))!/1609.34 < 1000){
                    distance = "\(Double(round((tempLocation?.distance(from: currentLocation!))!/1609.34 * 100)/100)) mi. away"
                }else{
                    distance = "1000+ mi. away"
                }
                if(expandNearby){
                    cell.contentView.isHidden = false
                }else{
                    cell.contentView.isHidden = true
                }
                cell.separatorInset = UIEdgeInsetsMake(0, 14, 0, 14)
                var boldText = "\n\(project.state), \(project.country)\n\(project.certification_level.capitalized) • \(distance)"
                var mutableParagraphStyle = NSMutableParagraphStyle()
                
                // *** set LineSpacing property in points ***
                mutableParagraphStyle.lineSpacing = 4 // Whatever line spacing you want in points
                //bold.addAttribute(NSAttributedStringKey.paragraphStyle , value: mutableParagraphStyle, range: NSMakeRange(0, boldText.count))
                
                
                var cert_color = UIColor()
                if(project.certification_level.lowercased() == "certified"){
                    cert_color = UIColor(red:76/255, green:175/255, blue:85/255, alpha:1.0)
                    boldText = "\n\(project.state), \(project.country)\n\(project.certification_level.capitalized) • \(distance)"
                }else if(project.certification_level.lowercased() == "gold"){
                    cert_color = UIColor(red:198/255, green:162/255, blue:0/255, alpha:1.0)
                    boldText = "\n\(project.state), \(project.country)\n\(project.certification_level.capitalized) • \(distance)"
                }else if(project.certification_level.lowercased() == "platinum"){
                    cert_color = UIColor(red:77/255, green:77/255, blue:77/255, alpha:1.0)
                    boldText = "\n\(project.state), \(project.country)\n\(project.certification_level.capitalized) • \(distance)"
                }else if(project.certification_level.lowercased() == "silver"){
                    cert_color = UIColor(red:110/255, green:130/255, blue:142/255, alpha:1.0)
                    boldText = "\n\(project.state), \(project.country)\n\(project.certification_level.capitalized) • \(distance)"
                }else {
                    cert_color = UIColor(red:21/255, green:101/255, blue:192/255, alpha:1.0)
                    boldText = "\n\(project.state), \(project.country)\n\(distance)"
                }
                let attrs = [NSAttributedStringKey.font : UIFont.AktivGrotesk_Rg(size: 12)] as [NSAttributedStringKey : Any]
                var boldString = NSMutableAttributedString(string: boldText, attributes:attrs)
                boldString.addAttribute(NSAttributedStringKey.paragraphStyle , value: mutableParagraphStyle, range: NSMakeRange(0, boldText.count))
                
                if(project.certification_level.lowercased() == "certified" || project.certification_level.lowercased() == "gold" || project.certification_level.lowercased() == "platinum" || project.certification_level.lowercased() == "silver"){
                    boldString.addAttribute(NSAttributedStringKey.foregroundColor , value: cert_color, range: NSMakeRange("\n\(project.state), \(project.country)\n".count, "\(project.certification_level)".count))
                    
                    boldString.addAttribute(NSAttributedStringKey.font , value: UIFont.AktivGrotesk_Md(size: 14), range: NSMakeRange("\n\(project.state), \(project.country)\n".count, "\(project.certification_level)".count))
                    
                    boldString.addAttribute(NSAttributedStringKey.foregroundColor , value: UIColor(red:0.53, green:0.60, blue:0.64, alpha:1.0), range: NSMakeRange("\n\(project.state), \(project.country)\n\(project.certification_level.uppercased()) • ".count, distance.count))
                }else{
                    boldString.addAttribute(NSAttributedStringKey.foregroundColor , value: UIColor(red:0.53, green:0.60, blue:0.64, alpha:1.0), range: NSMakeRange("\n\(project.state), \(project.country)\n".count, distance.count))
                }
                
                attributedString.append(boldString)
                cell.textLabel?.attributedText = attributedString
                //cell.projectname.attributedText = "\(project.title)\n\(project.address.replacingOccurrences(of: "\n", with: ""))"
                
                return cell
            }
        }

        
        
        
    
        //zxc
        

        
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
        let currentrow = self.titleArray.index(of: "operations")
        self.tableView.reloadRows(at: [IndexPath(row: currentrow!, section: 0)], with: .automatic)
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
        
        if let presenter = actionSheet.popoverPresentationController {
            let index = self.titleArray.index(of: "operations")
            let cell = self.tableView.cellForRow(at: IndexPath.init(row: index!, section: 0)) as! OperationsCell
            presenter.sourceView = cell.directionsLbl
            presenter.sourceRect = cell.directionsLbl.bounds
        }
        
        
        //self.presentViewController(shareMenu, animated: true, completion: nil)
        self.present(actionSheet, animated: true, completion: nil)
        
        
        
    }
    
    @objc func share(){
        // text to share
        let url = URL.init(string: "\(Details.path)")
        
        // set up activity view controller
        let textToShare = [ url! ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        //activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        
        // present the view controller
        
        if let presenter = activityViewController.popoverPresentationController {
            let index = self.titleArray.index(of: "operations")
            let cell = self.tableView.cellForRow(at: IndexPath.init(row: index!, section: 0)) as! OperationsCell
            presenter.sourceView = cell.shareLbl
            presenter.sourceRect = cell.shareLbl.bounds
        }
        
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
