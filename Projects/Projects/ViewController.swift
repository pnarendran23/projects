//
//  ViewController.swift
//  Projects
//
//  Created by Group X on 07/10/18.
//  Copyright © 2018 USGBC. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import SwiftyJSON
import Alamofire
import MapKit

class ViewController: UIViewController,UIGestureRecognizerDelegate, UITabBarDelegate,UISearchResultsUpdating, UITableViewDelegate,UITableViewDataSource, ProjectFilterDelegate, UISearchControllerDelegate {
    var request = MKLocalSearchRequest()
    var search = UISearchBar()
    fileprivate var loading = false
    let limit = 2000
    var frominfoView = false
    var isLarger = false
    var markerArray = [GMSMarker]()
    fileprivate var loadType = "init"
    var filterProjects = [Project]()
    fileprivate var pageNumber = 0
    var searchedProjects = [Project]()
    var markerTapped = false
    var size = 400
    var allDownloaded = false
    var from = 0
    @IBOutlet weak var arrowimage: UIImageView!
    var selected_searchbar = ""
    @IBOutlet weak var progressView: UIProgressView!    
    @IBOutlet weak var tableViewContainer: UIView!
    @IBOutlet weak var tableViewtopConstraint: NSLayoutConstraint!
    
    override func viewWillDisappear(_ animated: Bool) {
        //viewDidLayoutSubviews()
        //self.view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in (self.navigationController?.navigationBar.subviews)! {
            view.layoutMargins = UIEdgeInsets.zero
        }
        self.navigationItem.leftBarButtonItems = nil
        self.makeNavigationBarButtons()
        self.view.backgroundColor = tabbar.barTintColor
        //tabbar.invalidateIntrinsicContentSize()
    }
    
    
    func userDidSelectedFilter(changed: Bool, certificationsarray: NSMutableArray, ratingsarray: NSMutableArray, versionsarray: NSMutableArray, statesarray: NSMutableArray, countriesarray: NSMutableArray, countriesdict: NSMutableDictionary, statesdict: NSMutableDictionary, tagarray: NSMutableArray, totalCount: Int) {
        if(changed){
            self.tagarray = tagarray
            self.countriesdict = countriesdict
            self.statesdict = statesdict
            self.loading = true
            self.statesarray = statesarray
            self.countriesarray = countriesarray
            self.certificationsarray = certificationsarray
            self.ratingsarray = ratingsarray
            self.versionsarray = versionsarray
            self.totalCount = totalCount
            searchText = self.searchBar.text!
            pageNumber = 0
            loadType = "init"
            var tempstates = NSMutableArray()
            var tempcountries = NSMutableArray()
            var loopstates = NSMutableArray()
            let path = Bundle.main.path(forResource: "countries", ofType: "json")
            let jsonData = NSData(contentsOfFile:path!)
            var publications: [Publication] = []
            var localPublications: [Publication] = []
            var json = JSON()
            do{
                json = try JSON(data: jsonData! as Data)
            }catch let error as NSError{
                
            }
            print("Countries are", json["countries"])
            var countryjson = json.dictionaryObject!
            var countries = countryjson["countries"] as! [String : Any]
            var temp = self.countriesarray.mutableCopy() as! NSMutableArray
            temp.remove("")
            loopstates = self.statesarray.mutableCopy() as! NSMutableArray
            loopstates.remove("")
            if(statesdict.count > 0){
                for i in loopstates{
                    var loopstate = i as! String
                    if(loopstate != ""){
                        var currentstate = ""
                        for i in temp{
                            var str = i as! String
                            var currentcountry = ""
                            for (key,value) in countries{
                                if(str == value as! String){
                                    currentcountry = key as! String
                                    break
                                }
                            }
                            
                            var states = countryjson["divisions"] as! [String : Any]
                            if(states[currentcountry] != nil){
                                var state = states[currentcountry] as! [String : Any]
                                for (key,value) in state{
                                    print(key,value,loopstate)
                                    if(value as! String == loopstate){
                                        currentstate = "\(value) [\(key)]"
                                        break
                                    }
                                }
                            }
                            
                        }
                        if(currentstate != ""){
                            tempstates.add(currentstate)
                        }
                    }
                }
            }
            if(countriesdict.count > 0){
                for i in countriesarray{
                    var str = i as! String
                    if(str != ""){
                        tempcountries.add(self.countriesdict[str])
                    }
                }}
            
            self.category = Payloads().makePayloadForProject(certificationsarray: certificationsarray, ratingsarray: ratingsarray, versionsarray: versionsarray, statesarray : tempstates, countriesarray : tempcountries)
            self.totalCount = totalCount
            self.mapView.clear()
            print(self.category)
            let tempcerts = certificationsarray.mutableCopy() as! NSMutableArray
            let tempratings = ratingsarray.mutableCopy() as! NSMutableArray
            let tempversions = versionsarray.mutableCopy() as! NSMutableArray
            let tempstate = statesarray.mutableCopy() as! NSMutableArray
            let tempcountry = tempcountries.mutableCopy() as! NSMutableArray
            tempcerts.remove("")
            tempratings.remove("")
            tempversions.remove("")
            tempstate.remove("")
            tempcountry.remove("")
            DispatchQueue.main.async {
                self.searchedProjects = [Project]()
                self.filterProjects = [Project]()
                self.tableView.reloadData()
                if(tempcerts.count > 0 || tempratings.count > 0 || tempversions.count > 0 || tempstate.count > 0 || tempcountry.count > 0){
                    //CATransaction.begin()
                    //CATransaction.setValue(2.0, forKey: kCATransactionAnimationDuration)
                    //let camera = GMSCameraPosition.camera(withLatitude: self.mapView.camera.target.latitude , longitude: self.mapView.camera.target.longitude, zoom: 8)
                    //self.mapView.camera = camera
                    self.loadData()
                    self.navigationItem.rightBarButtonItems = nil
                    self.makeNavigationBarButtons()
                    //self.mapView.animate(to: GMSCameraPosition.camera(withTarget: self.mapView.camera.target, zoom: 8))
                    CATransaction.commit()
                    //self.mapView.animate(toZoom: 6)
                    //Apimanager.shared.stopAllSessions()
                    //self.searchProjects()
                }else{
                    self.navigationItem.rightBarButtonItems = nil
                    self.makeNavigationBarButtons()
                    self.loadData()
                }
            //loadProjects(category: category, search: searchText, page: pageNumber, loadType: loadType)
            //loadProjectsWithPagination(filterChanged: filterChanged, id: self.scrollId, category: category, loadType: loadType)
                //Utility.showLoading()
            }
            //self.loadProjectsElastic(search: self.searchText, category: self.category)
        }
    }
    
    
    //"Schools","Offices","Retail","Case studies"
    let categories = ["Schools","Offices","Retail","Case studies","Schools","Offices","Retail","Case studies","Schools","Offices","Retail","Case studies","Schools","Offices","Retail","Case studies","Schools","Offices","Retail","Case studies","Schools","Offices","Retail","Case studies"]
    var totalRecords = 0
    var totalCount = 0
    var ratingsarray = NSMutableArray()
    var versionsarray = NSMutableArray()
    var certificationsarray = NSMutableArray()
    var countriesdict = NSMutableDictionary()
    var statesdict = NSMutableDictionary()
    var statesarray = NSMutableArray()
    
    var countriesarray = NSMutableArray()
    var tagarray = NSMutableArray()
    var states = NSMutableArray()
    var countries = NSMutableArray()
    var selectedfilter : [String] = ["all","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    fileprivate var searchText = ""
    var category = ""
    
    @IBOutlet weak var tableView: UITableView!
    var searchOpen = false
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tabbar: UITabBar!
    var currentPosition = GMSCameraPosition()
    @IBOutlet weak var slideUpView: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    var bounds : GMSCoordinateBounds?
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var placesClient: GMSPlacesClient?
    var zoomLevel: Float = 15.0
    var projects = [Project]()
    var clusterManager: GMUClusterManager?
    var queryingLat = 0.0
    var timer = Timer()
    var queryingLng = 0.0
    var queryingDistance = 0.0
    @IBOutlet weak var slideViewTopConstraint: NSLayoutConstraint!

    var arrCountry = [String]();
    var arrProjects = [String]()
    var arrFilter:[String] = []
    
    
    
    func updateSearchResults(for searchController: UISearchController) {
        // To show another search view controller mapViewTopConstraint.constant = 54
            //mapView.isHidden = true

            //self.tableView.reloadData()
        
    }
    
    
    @objc func searchProjects(){
        
        var  bottomLeftCoord = mapView.projection.visibleRegion().nearLeft;
        var bottomRightCoord = mapView.projection.visibleRegion().nearRight;
        
        let point = mapView.center;
        var coor = self.mapView.projection.coordinate(for: point)
        
        
        var distanceMetres = GMSGeometryDistance(bottomLeftCoord, bottomRightCoord)
        distanceMetres = Double(self.mapView.getRadius() * 0.000621371193 * 0.8)
        queryingDistance = distanceMetres
        filterProjects = [Project]()
        coor = self.mapView.projection.coordinate(for: point)
        if(locationManager.location != nil){
            let region = CLCircularRegion.init(center: coor, radius: distanceMetres, identifier: "myRegion")
            if(region.contains((locationManager.location?.coordinate)!)){
                coor = (locationManager.location?.coordinate)!
            }
        }
        self.queryingLat = (coor.latitude)
        self.queryingLng = (coor.longitude)
        
        DispatchQueue.main.async {
            self.searchProjectUsingLocation(search: self.search.text!, category: self.category, lat: self.queryingLat, lng: self.queryingLng, distance: self.queryingDistance)
        }
    }
    
    func loadProjectsElastic(search: String, category: String){
        //sizee was 500000
        
        
        Apimanager.shared.getProjectsElasticForMap (from: 0, sizee: 100, search: search, category: category, callback: {(totalRecords, projects, code) in
            if(code == -1 && projects != nil){
                //self.totalRecords = totalRecords!
                self.projects = projects!
                //self.lastRecordsCount = projects!.count
                //self.filterProjects = self.projects
                DispatchQueue.main.async {
                    Utility.hideLoading()
                }
//                if(self.filterProjects.count == 0){
//                    if(self.navigationController != nil){
//                        Utility.showToast(y: self.navigationController!.navigationBar.frame.size.height, message:"Not found")
//                    }
//                }
                if(CLLocationManager.locationServicesEnabled()){
//                    self.locationManager.delegate = self
//                    self.locationManager.requestAlwaysAuthorization()
//                    self.mapView?.isMyLocationEnabled = true
//
//                    //Location Manager code to fetch current location
//                    self.locationManager.delegate = self
//                    self.locationManager.startUpdatingLocation()
                    //self.loadMapView()
                }else{
                    print("Not allowed")
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
    
    func constructCategory() -> [[String : Any]]{
        var dict = [[String : Any]]()
        var temp = [String]()
        for i in certificationsarray{
            if(i as! String != ""){
                temp.append(i as! String)
            }
        }
        if(temp.count > 0){
            dict.append(["terms": ["certification_level.raw" : temp ]])
        }
        temp = [String]()
        for i in countriesarray{
            if(i as! String != ""){
                temp.append(i as! String)
            }
        }
        if(temp.count > 0){
            dict.append(["terms": ["add_country.raw" : temp ]])
        }
        
        temp = [String]()
        for i in statesarray{
            if(i as! String != ""){
                temp.append(i as! String)
            }
        }
        if(temp.count > 0){
            dict.append(["terms": ["add_state.raw" : temp ]])
        }
        
        temp = [String]()
        for i in ratingsarray{
            if(i as! String != ""){
                temp.append(i as! String)
            }
        }
        if(temp.count > 0){
            dict.append(["terms": ["rating_system.raw" : temp ]])
        }
        
        temp = [String]()
        for i in versionsarray{
            if(i as! String != ""){
                temp.append(i as! String)
            }
        }
        if(temp.count > 0){
            dict.append(["terms": ["rating_system_version.raw" : temp ]])
        }
        print(dict)
        
        return dict
    }
    
    
    func loadProjectsElasticUsingLocation(search: String, category: String, lat : Double, lng : Double, distance : Double){
        //sizee was 500000
        
        if(!allDownloaded){
            var dict = [[String : Any]]()
            dict = constructCategory()
            self.navigationItem.rightBarButtonItems = nil
            //self.makeNavigationBarButtons()
        print(lat)
        print(lng)
        print(distance)
        Apimanager.shared.getProjectsElasticForMapNew (from: self.from, sizee : size, search : search, category : dict, lat : lat, lng : lng, distance : distance, callback: {(totalRecords, projects, code) in
            if(code == -1 && projects != nil){
                //self.lastRecordsCount = projects!.count
                //self.filterProjects = self.projects
                DispatchQueue.main.async {
                    self.totalRecords = totalRecords!
                    for i in projects!{
                        self.projects.append(i)
                    }
                    
                    self.searchedProjects = self.projects
                    self.tableView.reloadData()
                    Utility.hideLoading()
                    self.arrProjects = [String]()
                    self.arrFilter = [String]()
                    self.arrCountry = [String]()
//                    if(self.totalRecords <= 6000){
//                        self.progressView.setProgress(Float(self.projects.count)/Float(self.totalRecords), animated: true)
//                    }else{
//                        self.progressView.setProgress(Float(self.projects.count)/Float(6000), animated: true)
//                    }
                    
                    
                        if(self.from == 0 && totalRecords! == 0 && self.markerArray.count == 0){
                            self.progressView.isHidden = true
                            self.tableView.isHidden = true
                            self.loadMapView(temp: projects!)
                        }else if(self.totalRecords <= self.limit){
                            self.from = self.from + self.size
                            self.tableView.reloadData()
                            self.loadMapView(temp: projects!)
                            if(self.totalRecords != self.searchedProjects.count){
                                self.loadProjectsElasticUsingLocation(search: search, category: category, lat: self.mapView.camera.target.latitude, lng: self.mapView.camera.target.longitude, distance: distance)
                            }
                        }else if(self.totalRecords > self.limit && projects!.count > 0){
                            self.mapView.clear()
                            self.progressView.isHidden = true
                            self.from = self.from + self.size
                            self.loadMapView(temp: projects!)
                            Utility.showToast(y: self.searchBar.frame.origin.y + self.searchBar.frame.size.height - UIApplication.shared.statusBarFrame.size.height, message: "Showing \(self.from) of \(self.totalRecords) projects")
                            self.allDownloaded = true
                        }
                        
                        
                        /*else{
                            self.tableView.isHidden = false
                            print("Progress",Float(self.projects.count/self.totalRecords))
                                if(projects!.count > 0 && self.totalRecords <= self.limit){
                                self.from = self.from + self.size
                                self.isLarger = false
                                    Utility.hideToast()
                                self.tableView.reloadData()
                                self.loadMapView(temp: projects!)
                            self.loadProjectsElasticUsingLocation(search: search, category: category, lat: lat , lng: lng, distance: distance)
                                //}else{
                                }else if(projects!.count > 0 && self.totalRecords > self.limit){
                                    if(self.projects.count <= 6000){
                                        if(self.totalRecords <= 6000){
                                            self.progressView.setProgress(Float(self.projects.count)/Float(self.totalRecords), animated: true)
                                        }else{
                                            self.progressView.setProgress(Float(self.projects.count)/Float(6000), animated: true)
                                        }
                                        self.from = self.from + self.size
                                        self.isLarger = false
                                        Utility.hideToast()
                                        self.loadProjectsElasticUsingLocation(search: search, category: category, lat: lat , lng: lng, distance: distance)
                                    }
                                    else{
                                        self.progressView.setProgress(Float(self.projects.count)/Float(6000), animated: true)
                                        self.progressView.isHidden = true
                                        self.tableView.reloadData()
                                        self.setupClusters()
                                    }
                                }else{
                                    if(self.totalRecords > 2000 && self.projects.count <= 6000){
                                        self.progressView.setProgress(Float(self.projects.count)/Float(6000), animated: true)
                                        self.setupClusters()
                                    }
                                print(self.progressView.progress)
                                self.progressView.isHidden = true                                
                                self.tableView.reloadData()
                                self.allDownloaded = true
                            }
                        }*/
                   
                }
            }else{
                if(code == 401){
                    
                }else if(code != -999 && code != nil && code != 0 && code != 200){
                    DispatchQueue.main.async {
                        self.allDownloaded = false
                        self.isLarger = false
                        Utility.hideLoading()
                    }
                    if(self.navigationController != nil){
                        self.allDownloaded = false
                        self.isLarger = false
                        //Utility.showToast(y: self.navigationController!.navigationBar.frame.size.height, message: "Something went wrong")
                    }
                }
                
            }
        })
        }else{
            self.filterProjects = [Project]()
            self.searchedProjects = [Project]()
            self.tableView.reloadData()
        }
    }
    
    
    func searchProjectUsingLocation(search: String, category: String, lat : Double, lng : Double, distance : Double){
        //sizee was 500000
        var dict = [[String : Any]]()
        dict = constructCategory()
        self.navigationItem.rightBarButtonItems = nil
        //self.makeNavigationBarButtons()
            Apimanager.shared.searchProjectsElasticForMapNew (from: 0, sizee : 100, search : search, category : dict, callback: {(totalRecords, projects, code) in
                if(code == -1 && projects != nil){
                    DispatchQueue.main.async {
                    self.searchedProjects = projects!
                    self.totalRecords = totalRecords!
                        if(projects!.count > 0){
                    self.filterProjects = projects!
                    }
                    //self.lastRecordsCount = projects!.count
                    self.projects = self.filterProjects
                    self.allDownloaded = false
                    self.projects = self.searchedProjects
                    Utility.hideLoading()
                        self.arrProjects = [String]()
                        self.arrFilter = [String]()
                        self.isLarger = false
                        print(self.progressView.progress)
                        if(self.from == 0 && totalRecords! == 0 && self.searchedProjects.count == 0){
                            self.tableView.isHidden = true
                        }else{
                            self.tableView.isHidden = false
                        }
                        
                        
                        if(self.from == 0 && totalRecords! == 0 && self.markerArray.count == 0){
                            self.progressView.isHidden = true
                            self.tableView.isHidden = true
                            self.loadMapView(temp: projects!)
                        }else if(self.totalRecords < self.limit){
                            self.from = self.from + self.size
                        }else if(self.totalRecords > self.limit && projects!.count > 0){
                            self.mapView.clear()
                            self.progressView.isHidden = true
                            self.from = self.from + self.size
                            self.loadMapView(temp: projects!)
                            if(self.tableViewContainer.isHidden == true && self.mapViewTopConstraint.constant != 0){
                            Utility.showToast(y: self.searchBar.frame.origin.y + self.searchBar.frame.size.height - UIApplication.shared.statusBarFrame.size.height, message: "Showing \(self.from) of \(self.totalRecords) projects")
                            }
                            self.allDownloaded = true
                        }
                        self.tableView.reloadData()
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
    
    var locationsearchTxt = ""
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //if (self.search.isFirstResponder) {
            mapView.isHidden = false
            let camera = GMSCameraPosition.camera(withLatitude: Double(self.searchedProjects[indexPath.row].lat)! ,
                                                  longitude: Double(self.searchedProjects[indexPath.row].long)!,
                                                  zoom: zoomLevel + 5)
            if(self.allDownloaded == true){
                self.from = 0
            }
            frominfoView = false
            self.tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: "ProjectDetailsViewController", sender: indexPath.row)
            //mapView.animate(to: camera)
            
            //self.search.resignFirstResponder()
        //}
//        else{
//            let camera = GMSCameraPosition.camera(withLatitude: (locationManager.location?.coordinate.latitude)! ,
//                                                  longitude: (locationManager.location?.coordinate.longitude)!,
//                                                  zoom: zoomLevel)
//            mapView.animate(to: camera)
//            self.searchBar.resignFirstResponder()
//        }
        
        //self.tableViewContainer.isHidden = true
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        
        return UITableViewAutomaticDimension
    }
    
    //MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.searchedProjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let project = searchedProjects[indexPath.row]
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
                if(locationManager.location != nil){
                if(tempLocation!.distance(from: locationManager.location!)/1609.34 < 1000){
                    distance = "\(Double(round(tempLocation!.distance(from: locationManager.location!)/1609.34 * 100)/100)) m. away"
                }else{
                    distance = "1000+ mi. away"
                }
                }
                var boldText = "\n\(project.state), \(project.country)\n\(project.certification_level.capitalized) • \(distance)"
                var mutableParagraphStyle = NSMutableParagraphStyle()
                
                // *** set LineSpacing property in points ***
                mutableParagraphStyle.lineSpacing = 4 // Whatever line spacing you want in points
                //bold.addAttribute(NSAttributedStringKey.paragraphStyle , value: mutableParagraphStyle, range: NSMakeRange(0, boldText.count))
                
                cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 14)
                
                var cert_color = UIColor()
                if(project.certification_level.lowercased() == "certified" && distance.count > 0){
                    cert_color = UIColor(red:76/255, green:175/255, blue:85/255, alpha:1.0)
                    boldText = "\n\(project.state), \(project.country)\n\(project.certification_level.capitalized) • \(distance)"
                }else if(project.certification_level.lowercased() == "gold" && distance.count > 0){
                    cert_color = UIColor(red:198/255, green:162/255, blue:0/255, alpha:1.0)
                    boldText = "\n\(project.state), \(project.country)\n\(project.certification_level.capitalized) • \(distance)"
                }else if(project.certification_level.lowercased() == "platinum" && distance.count > 0){
                    cert_color = UIColor(red:77/255, green:77/255, blue:77/255, alpha:1.0)
                    boldText = "\n\(project.state), \(project.country)\n\(project.certification_level.capitalized) • \(distance)"
                }else if(project.certification_level.lowercased() == "silver" && distance.count > 0){
                    cert_color = UIColor(red:110/255, green:130/255, blue:142/255, alpha:1.0)
                    boldText = "\n\(project.state), \(project.country)\n\(project.certification_level.capitalized) • \(distance)"
                }else if(project.certification_level.lowercased() == "" && distance.count > 0){
                    cert_color = UIColor(red:21/255, green:101/255, blue:192/255, alpha:1.0)
                    boldText = "\n\(project.state), \(project.country)\n\(distance)"
                }else if(project.certification_level.lowercased() == "" && distance.count == 0){
                    cert_color = UIColor(red:21/255, green:101/255, blue:192/255, alpha:1.0)
                    boldText = "\n\(project.state), \(project.country)"
                }else if(project.certification_level.lowercased() == "certified" && distance.count == 0){
                    cert_color = UIColor(red:76/255, green:175/255, blue:85/255, alpha:1.0)
                    boldText = "\n\(project.state), \(project.country)\n\(project.certification_level.capitalized)"
                }else if(project.certification_level.lowercased() == "gold" && distance.count == 0){
                    cert_color = UIColor(red:198/255, green:162/255, blue:0/255, alpha:1.0)
                    boldText = "\n\(project.state), \(project.country)\n\(project.certification_level.capitalized)"
                }else if(project.certification_level.lowercased() == "silver" && distance.count == 0){
                    cert_color = UIColor(red:110/255, green:130/255, blue:142/255, alpha:1.0)
                    boldText = "\n\(project.state), \(project.country)\n\(project.certification_level.capitalized)"
                }else if(project.certification_level.lowercased() == "platinum" && distance.count == 0){
                    cert_color = UIColor(red:77/255, green:77/255, blue:77/255, alpha:1.0)
                    boldText = "\n\(project.state), \(project.country)\n\(project.certification_level.capitalized)"
                }
                let attrs = [NSAttributedStringKey.font : cell.address.font] as [NSAttributedStringKey : Any]
                var boldString = NSMutableAttributedString(string: boldText, attributes:attrs)
                boldString.addAttribute(NSAttributedStringKey.paragraphStyle , value: mutableParagraphStyle, range: NSMakeRange(0, boldText.count))
                
                
                var t = "\n"
                if(project.state.count > 0){
                    t = t + project.state + ", "
                }
                if(project.country.count > 0){
                    t = t + project.country + "\n"
                }
                
                if(project.certification_level.lowercased() == "certified" || project.certification_level.lowercased() == "gold" || project.certification_level.lowercased() == "platinum" || project.certification_level.lowercased() == "silver"){
                boldString.addAttribute(NSAttributedStringKey.foregroundColor , value: cert_color, range: NSMakeRange("\(t)".count, "\(project.certification_level)".count))
                
                boldString.addAttribute(NSAttributedStringKey.font , value: UIFont.AktivGrotesk_Md(size: 14), range: NSMakeRange("\(t)".count, "\(project.certification_level)".count))
                
                boldString.addAttribute(NSAttributedStringKey.foregroundColor , value: UIColor(red:0.53, green:0.60, blue:0.64, alpha:1.0), range: NSMakeRange("\(t)\(project.certification_level.uppercased()) • ".count, distance.count))
                }else{
                    if(distance.count > 0){
                        boldString.addAttribute(NSAttributedStringKey.foregroundColor , value: UIColor(red:0.53, green:0.60, blue:0.64, alpha:1.0), range: NSMakeRange("\(t)".count, distance.count))
                    }
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
                if(locationManager.location != nil){
                if(tempLocation!.distance(from: locationManager.location!)/1609.34 < 1000){
                    distance = "\(Double(round(tempLocation!.distance(from: locationManager.location!)/1609.34 * 100)/100)) mi. away"
                }else{
                    distance = "1000+ mi. away"
                }
                }
                cell.separatorInset = UIEdgeInsetsMake(0, 13, 0, 14)
                var boldText = "\n\(project.state), \(project.country)\n\(project.certification_level.capitalized) • \(distance)"
                var mutableParagraphStyle = NSMutableParagraphStyle()
                
                // *** set LineSpacing property in points ***
                mutableParagraphStyle.lineSpacing = 4 // Whatever line spacing you want in points
                //bold.addAttribute(NSAttributedStringKey.paragraphStyle , value: mutableParagraphStyle, range: NSMakeRange(0, boldText.count))
                
 
                var cert_color = UIColor()
                if(project.certification_level.lowercased() == "certified" && distance.count > 0){
                    cert_color = UIColor(red:76/255, green:175/255, blue:85/255, alpha:1.0)
                    boldText = "\n\(project.state), \(project.country)\n\(project.certification_level.capitalized) • \(distance)"
                }else if(project.certification_level.lowercased() == "gold" && distance.count > 0){
                    cert_color = UIColor(red:198/255, green:162/255, blue:0/255, alpha:1.0)
                    boldText = "\n\(project.state), \(project.country)\n\(project.certification_level.capitalized) • \(distance)"
                }else if(project.certification_level.lowercased() == "platinum" && distance.count > 0){
                    cert_color = UIColor(red:77/255, green:77/255, blue:77/255, alpha:1.0)
                    boldText = "\n\(project.state), \(project.country)\n\(project.certification_level.capitalized) • \(distance)"
                }else if(project.certification_level.lowercased() == "silver" && distance.count > 0){
                    cert_color = UIColor(red:110/255, green:130/255, blue:142/255, alpha:1.0)
                    boldText = "\n\(project.state), \(project.country)\n\(project.certification_level.capitalized) • \(distance)"
                }else if(project.certification_level.lowercased() == "" && distance.count > 0){
                    cert_color = UIColor(red:21/255, green:101/255, blue:192/255, alpha:1.0)
                    boldText = "\n\(project.state), \(project.country)\n\(distance)"
                }else if(project.certification_level.lowercased() == "" && distance.count == 0){
                    cert_color = UIColor(red:21/255, green:101/255, blue:192/255, alpha:1.0)
                    boldText = "\n\(project.state), \(project.country)"
                }else if(project.certification_level.lowercased() == "certified" && distance.count == 0){
                    cert_color = UIColor(red:76/255, green:175/255, blue:85/255, alpha:1.0)
                    boldText = "\n\(project.state), \(project.country)\n\(project.certification_level.capitalized)"
                }else if(project.certification_level.lowercased() == "gold" && distance.count == 0){
                    cert_color = UIColor(red:198/255, green:162/255, blue:0/255, alpha:1.0)
                    boldText = "\n\(project.state), \(project.country)\n\(project.certification_level.capitalized)"
                }else if(project.certification_level.lowercased() == "silver" && distance.count == 0){
                    cert_color = UIColor(red:110/255, green:130/255, blue:142/255, alpha:1.0)
                    boldText = "\n\(project.state), \(project.country)\n\(project.certification_level.capitalized)"
                }else if(project.certification_level.lowercased() == "platinum" && distance.count == 0){
                    cert_color = UIColor(red:77/255, green:77/255, blue:77/255, alpha:1.0)
                    boldText = "\n\(project.state), \(project.country)\n\(project.certification_level.capitalized)"
                }
                let attrs = [NSAttributedStringKey.font : UIFont.AktivGrotesk_Rg(size: 12)] as [NSAttributedStringKey : Any]
                var boldString = NSMutableAttributedString(string: boldText, attributes:attrs)
                boldString.addAttribute(NSAttributedStringKey.paragraphStyle , value: mutableParagraphStyle, range: NSMakeRange(0, boldText.count))
                
                var t = "\n"
                if(project.state.count > 0){
                    t = t + project.state + ", "
                }
                if(project.country.count > 0){
                    t = t + project.country + "\n"
                }
                
                if(project.certification_level.lowercased() == "certified" || project.certification_level.lowercased() == "gold" || project.certification_level.lowercased() == "platinum" || project.certification_level.lowercased() == "silver"){
                    boldString.addAttribute(NSAttributedStringKey.foregroundColor , value: cert_color, range: NSMakeRange("\(t)".count, "\(project.certification_level)".count))
                    
                    boldString.addAttribute(NSAttributedStringKey.font , value: UIFont.AktivGrotesk_Md(size: 14), range: NSMakeRange("\(t)".count, "\(project.certification_level)".count))
                    
                    boldString.addAttribute(NSAttributedStringKey.foregroundColor , value: UIColor(red:0.53, green:0.60, blue:0.64, alpha:1.0), range: NSMakeRange("\(t)\(project.certification_level.uppercased()) • ".count, distance.count))
                }else{
                    if(distance.count > 0){
                        boldString.addAttribute(NSAttributedStringKey.foregroundColor , value: UIColor(red:0.53, green:0.60, blue:0.64, alpha:1.0), range: NSMakeRange("\(t)".count, distance.count))
                    }
                }
                
                attributedString.append(boldString)
                cell.textLabel?.attributedText = attributedString
                //cell.projectname.attributedText = "\(project.title)\n\(project.address.replacingOccurrences(of: "\n", with: ""))"
                
                return cell
            }        
        
    }
    
    func configureCell(cell: UITableViewCell, forRowAtIndexPath: IndexPath) {
        // 3
        if ((self.search.isFirstResponder || mapViewTopConstraint.constant == 0) && arrFilter.count > 0) {
            cell.textLabel?.text = arrFilter[forRowAtIndexPath.row]
        } else {
            cell.textLabel?.text = arrCountry[forRowAtIndexPath.row]
        }
    }
    
    
    @objc func wasDraggedUp(gestureRecognizer: UISwipeGestureRecognizer) {

        // To move view to any position
/*        if gestureRecognizer.state == UIGestureRecognizerState.began || gestureRecognizer.state == UIGestureRecognizerState.changed {
            let translation = gestureRecognizer.translation(in: self.view)
            print(gestureRecognizer.view!.center.y)
            if(gestureRecognizer.view!.center.y < 555) {
                gestureRecognizer.view!.center = CGPoint(x : gestureRecognizer.view!.center.x, y:gestureRecognizer.view!.center.y + translation.y)
            }else {
                gestureRecognizer.view!.center = CGPoint(x:gestureRecognizer.view!.center.x, y:554)
            }
            
            gestureRecognizer.setTranslation(CGPoint(x:0,y:0), in: self.view)
        }*/
        openDrawer()
        
        print("Swipe up")
        if(gestureRecognizer.state == .changed || gestureRecognizer.state == .began){
            print(gestureRecognizer.view?.center.y)
        }
        
        
    }
    
    override func transition(from fromViewController: UIViewController, to toViewController: UIViewController, duration: TimeInterval, options: UIViewAnimationOptions = [], animations: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        
        self.view.layoutIfNeeded()
    }
    

    
    
    func openDrawer(){
        self.arrowimage.image = UIImage.init(named: "arrow_down")
        slideViewTopConstraint.constant = 0 //74
        UIView.animate(withDuration: 1.0,
                       delay: 0.0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.0,
                       options: .curveEaseOut,
                       animations: {
                        //self.navigationController?.navigationBar.barTintColor = UIColor.white
                        
                        //self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    
    func closeDrawer(){
        self.arrowimage.image = UIImage.init(named: "arrow_up")
        slideViewTopConstraint.constant = self.view.frame.size.height - self.tabbar.frame.size.height * 2
        UIView.animate(withDuration: 1.0,
                       delay: 0.0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.0,
                       options: .curveEaseOut,
                       animations: {
                        //self.view.layoutIfNeeded()
                        //self.navigationController?.navigationBar.barTintColor = UIColor.white
                        //self.makeNavigationBarButtons()
        }, completion: nil)
    }
    
    @objc func wasDraggedDown(gestureRecognizer: UISwipeGestureRecognizer) {
        
        closeDrawer()
        
    }
    
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if(item.tag == 0){
            self.slideUpView.isHidden = !self.slideUpView.isHidden
            if(self.slideUpView.isHidden){
                self.closeDrawer()
                tabbar.selectedItem = nil
            }else{
                self.closeDrawer()
            }
        }
    }
    
    @objc func rotated() {
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
            print("Landscape")
        }
        
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            print("Portrait")
        }
        
        self.view.layoutIfNeeded()
        
        if(slideViewTopConstraint.constant > 200){
            closeDrawer()
        }else{
            openDrawer()
        }
        collectionView?.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
    
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {        
        self.tableViewContainer.isHidden = true
         self.searchBar.isHidden = false
        DispatchQueue.main.async {
            
            //self.makeNavigationBarButtons()
        }
        
        //slideUpView.isHidden = false
        self.arrProjects = [String]()
        arrFilter = [String]()
        
        self.allDownloaded = false
        self.from = 0
        self.projects = [Project]()
        let distanceinKms = Double(self.mapView.getRadius() * 0.000621371193 * 0.8)
        DispatchQueue.main.async {
            if(distanceinKms == distanceinKms){
                Apimanager.shared.stopAllSessions()
                self.queryingLat = self.mapView.camera.target.latitude
                self.queryingLng = self.mapView.camera.target.longitude
                self.queryingDistance = distanceinKms
                self.allDownloaded = false
                self.from = 0
                self.markerArray = [GMSMarker]()
                self.projects = [Project]()
                self.isLarger = false
                self.loadProjectsElasticUsingLocation(search: self.search.text!, category: self.category, lat: self.mapView.camera.target.latitude, lng: self.mapView.camera.target.longitude, distance: distanceinKms)
            }else{
                Utility.showToast(y: self.navigationController!.navigationBar.frame.size.height + self.searchBar.frame.size.height, message: "Use precised region to explore projects")
                self.allDownloaded = true
                Apimanager.shared.stopAllSessions()
                self.mapView.clear()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListHeader")
//        var title = "Projects"
//        (cell as? ListHeader)?.projects.text = "\(title)"
//        if(self.totalRecords <= 1){
//            (cell as? ListHeader)?.rightside.text = "\(self.totalRecords) Result"
//        }else{
//            (cell as? ListHeader)?.rightside.text = "\(self.totalRecords) Results"
//        }
        
        let tempcerts = self.certificationsarray.mutableCopy() as! NSMutableArray
        let tempratings = self.ratingsarray.mutableCopy() as! NSMutableArray
        let tempversions = self.versionsarray.mutableCopy() as! NSMutableArray
        let tempstate = self.statesarray.mutableCopy() as! NSMutableArray
        let tempcountry = self.countriesarray.mutableCopy() as! NSMutableArray
        tempcerts.remove("")
        tempratings.remove("")
        tempversions.remove("")
        tempstate.remove("")
        tempcountry.remove("")
        var title = "Projects Nearby"
        if(tempcerts.count > 0 || tempratings.count > 0 || tempversions.count > 0 || tempstate.count > 0 || tempcountry.count > 0 || self.search.isFirstResponder || (self.search.text?.count)! > 0){
            title = "Projects"
        }
        
        (cell as? ListHeader)?.projects.text = "\(title) (\(self.totalRecords))"
        (cell as? ListHeader)?.rightside.text = ""
        
        if((search.text?.count)! == 0 && self.searchedProjects.count == 0){
            (cell as? ListHeader)?.projects.text = ""
            (cell as? ListHeader)?.rightside.text = ""
        }
        
        if(self.totalRecords == 0 && self.searchedProjects.count == 0){
            (cell as? ListHeader)?.projects.text = ""
            (cell as? ListHeader)?.rightside.text = ""
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44//self.searchBar.frame.size.height;
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        print(self.tableView.frame.size.height)
        if (sender.direction == .down) {
            print("Swipe Down")
             self.searchBar.isHidden = false
            tableViewtopConstraint.constant = 0.58 * UIScreen.main.bounds.size.height
            UIView.animate(withDuration: 1.0,
                           delay: 0.0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.0,
                           options: .curveEaseOut,
                           animations: {
                            self.view.layoutIfNeeded()
                            //self.tableView.reloadData()
                            //self.mapView(self.mapView, idleAt: self.mapView.camera)
            }, completion: nil)
        }
        
        if (sender.direction == .up) {
            print("Swipe Up")
            tableViewtopConstraint.constant = 0
            UIView.animate(withDuration: 1.0,
                           delay: 0.0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.0,
                           options: .curveEaseOut,
                           animations: {
                            self.view.layoutIfNeeded()
                            self.searchBar.isHidden = true
            }, completion: nil)
        }
        self.navigationItem.leftBarButtonItems = nil
        self.makeNavigationBarButtons()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.isHidden = true
        tableViewtopConstraint.constant = 0.58 * UIScreen.main.bounds.size.height
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        
        leftSwipe.direction = .up
        rightSwipe.direction = .down
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        
        self.collectionView.delegate = nil
        self.collectionView.dataSource = nil
        self.tableView.tableFooterView = UIView.init(frame: .zero)
        self.searchBar.layer.borderColor = searchBar.barTintColor?.cgColor
        for family in UIFont.familyNames {
            print("\(family)")
            
            for name in UIFont.fontNames(forFamilyName: family) {
                print("   \(name)")
            }
        }
        self.tableView.estimatedRowHeight = UITableViewAutomaticDimension
        self.tableView.rowHeight = UITableViewAutomaticDimension
        slideUpView.isHidden = true
        tableView.register(UINib.init(nibName:"locationcell", bundle: nil), forCellReuseIdentifier: "locationcell")
        collectionView.register(UINib.init(nibName: "moreCollectionsView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "moreCollectionsView")
        
        tableView.register(UINib(nibName: "ProjectCellwithImage", bundle: nil), forCellReuseIdentifier: "ProjectCellwithImage")
        tableView.register(UINib(nibName: "ProjectCellwithoutImage", bundle: nil), forCellReuseIdentifier: "ProjectCellwithoutImage")
        tableView.register(UINib(nibName: "ListHeader", bundle: nil), forCellReuseIdentifier: "ListHeader")
        
        self.searchBar.delegate = self
        self.tableViewContainer.isHidden = true
        
         self.searchBar.isHidden = false
        // Do any additional setup after loading the view, typically from a nib.

        
        //searchBar.textField.clearButtonMode = .never
        //self.search.textField.clearButtonMode = .never
        
        (self.searchBar.value(forKey: "searchField") as? UITextField)?.font = UIFont.AktivGrotesk_Md(size: 14)
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        // Include the search bar within the navigation bar.
        
        self.definesPresentationContext = true;
        collectionView.register(UINib.init(nibName: "exploreGridCell", bundle: nil), forCellWithReuseIdentifier: "exploreGridCell")
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        //self.slideUpView.isHidden = true

        
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(wasDraggedUp(gestureRecognizer:)))
        gesture.direction = .up
        slideUpView.addGestureRecognizer(gesture)
        slideUpView.isUserInteractionEnabled = true
        gesture.delegate = self
        
        
        let gesture1 = UISwipeGestureRecognizer(target: self, action: #selector(wasDraggedDown(gestureRecognizer:)))
        gesture1.direction = .down
        slideUpView.addGestureRecognizer(gesture1)
        slideUpView.isUserInteractionEnabled = true
        gesture1.delegate = self

        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                print("Not Determined")
                print(CLLocationManager.authorizationStatus())
                //self.present(alertController, animated: true, completion: nil)
                
            case    .restricted:
                print("Restricted")
                
            case .denied:
                print("Denied")
                self.mapView.settings.myLocationButton = false
                let position = GMSCameraPosition.camera(withLatitude: 38.904449,
                                                        longitude: -77.046797,
                                                        zoom: self.zoomLevel)
                self.mapView.animate(to: position)
            case .authorizedAlways, .authorizedWhenInUse:
                self.mapView.settings.myLocationButton = true
                print("Access")
                if(CLLocationManager.locationServicesEnabled()){
                    self.locationManager.delegate = self
                    self.locationManager.requestAlwaysAuthorization()
                    self.mapView?.isMyLocationEnabled = true
                    
                    //Location Manager code to fetch current location
                    self.locationManager.delegate = self
                    self.mapView.settings.myLocationButton = true
                    self.locationManager.startUpdatingLocation()
                }else{
                    print("Not allowed")
                }
            }
        } else {
            
            print("Location services are not enabled")
        }
        
        if(UserDefaults.standard.integer(forKey: "prompted") == 0){
            UserDefaults.standard.set(1, forKey: "prompted")
            if(CLLocationManager.locationServicesEnabled()){
                                    self.locationManager.delegate = self
                                    self.locationManager.requestAlwaysAuthorization()
                                    self.mapView?.isMyLocationEnabled = true
                
                                    //Location Manager code to fetch current location
                                    self.locationManager.delegate = self
                                    self.locationManager.startUpdatingLocation()
            }else{
                print("Not allowed")
            }
        }
        
        makeNavigationBarButtons()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        self.navigationController?.navigationBar.tintColor = self.tabBarController?.tabBar.tintColor
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewWillAppear(_ animated: Bool) {
        searchBar.tintColor = UIColor.white
        searchBar.layer.borderWidth = 1
        self.navigationItem.leftBarButtonItems = nil
        self.makeNavigationBarButtons()
        viewDidLayoutSubviews()
        //self.navigationController?.navigationBar.barTintColor = UIColor.white
        //searchBar.layer.borderColor = UIColor.hex(hex: Colors.primaryColor).cgColor
        //right nav buttons
        //self.navigationController?.navigationBar.isTranslucent = true
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            let moreCollectionsView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "moreCollectionsView", for: indexPath)
            return moreCollectionsView
    }        
    func makeNavigationBarButtons(){
        let searchButton = UIButton(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
        searchButton.setImage(UIImage(named: "search"), for: .normal)
        searchButton.imageView?.contentMode = .scaleAspectFit
        searchButton.addTarget(self, action: #selector(self.handleSearch(_:)), for: .touchUpInside)
        let searchBarButton = UIBarButtonItem(customView: searchButton)
        
        let filterButton = UIButton(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
        let tempcerts = certificationsarray.mutableCopy() as! NSMutableArray
        let tempratings = ratingsarray.mutableCopy() as! NSMutableArray
        let tempversions = versionsarray.mutableCopy() as! NSMutableArray
        let tempstate = statesarray.mutableCopy() as! NSMutableArray
        let tempcountry = countriesarray.mutableCopy() as! NSMutableArray
        tempcerts.remove("")
        tempratings.remove("")
        tempversions.remove("")
        tempstate.remove("")
        tempcountry.remove("")
        if(tempcerts.count > 0 || tempratings.count > 0 || tempversions.count > 0 || tempstate.count > 0 || tempcountry.count > 0){
            filterButton.setImage(UIImage(named: "filtered"), for: .normal)
            let tintedImage = filterButton.imageView?.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            filterButton.imageView?.image = tintedImage
        }else{
            filterButton.setImage(UIImage(named: "Filter_BU"), for: .normal)
        }
        
        filterButton.imageView?.contentMode = .scaleAspectFit
        filterButton.addTarget(self, action: #selector(self.handleFilter(_:)), for: .touchUpInside)
        let filterBarButton = UIBarButtonItem(customView: filterButton)
        
        
        let listButton = UIButton(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
        if(self.tableViewtopConstraint.constant == 0.58 * UIScreen.main.bounds.size.height || self.tableView.isHidden == true){
            listButton.setImage(UIImage(named: "ListView_BU"), for: .normal)
        }else{
            listButton.setImage(UIImage(named: "map_black"), for: .normal)
        }
        listButton.imageView?.contentMode = .scaleAspectFit
        listButton.addTarget(self, action:#selector(self.handleList(_:)), for: .touchUpInside)
        let listBarButton = UIBarButtonItem(customView: listButton)
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            search = UISearchBar(frame: CGRect(x:-10, y:0, width:0.91 * UIScreen.main.bounds.size.width, height:20))
        }else{
            search = UISearchBar(frame: CGRect(x:-10, y:0, width:0.76 * UIScreen.main.bounds.size.width, height:20))
        }
        search.placeholder = "Search"
        
        if(UserDefaults.standard.object(forKey: "searchText") != nil){
            self.searchText = UserDefaults.standard.object(forKey: "searchText") as! String
            self.search.text = self.searchText
        }
        if(self.searchText.count > 0){
            //self.search.becomeFirstResponder()
        }
        search.barTintColor = UIColor.red
        search.tag = 23
        search.enablesReturnKeyAutomatically = false
        
        (search.value(forKey: "searchField") as? UITextField)?.font = UIFont.AktivGrotesk_Md(size: 14)
        search.delegate = self
        search.showsCancelButton = false
        let temp = UIBarButtonItem(customView: search)
        //self.searchController.searchBar;
        
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white] as [AnyHashable : NSObject]
        //[NSAttributedStringKey.foregroundColor:UIColor.white, kCTFontAttributeName : UIFont.gothamBook(size: 18) ] as [AnyHashable : NSObject]
        navigationController?.navigationBar.titleTextAttributes = textAttributes as! [NSAttributedStringKey : Any]
        self.navigationItem.title = "Projects"
        temp.customView?.translatesAutoresizingMaskIntoConstraints = true;
        var negativeSpace:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        negativeSpace.width = 17.0
        self.navigationItem.leftBarButtonItems = [temp, filterBarButton, listBarButton]
        self.navigationItem.rightBarButtonItems = nil
        var textField = search.value(forKey: "_searchField") as! UITextField
        //textField.clearButtonMode = .never
        //self.navigationItem.leftBarButtonItem =
    }
    
    @objc func handleList(_ sender: Any){
        if(tableViewtopConstraint.constant == 0){
            tableViewtopConstraint.constant = 0.58 * UIScreen.main.bounds.size.height
            UIView.animate(withDuration: 1.0,
                           delay: 0.0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.0,
                           options: .curveEaseOut,
                           animations: {
                            self.view.layoutIfNeeded()
                            //self.tableView.reloadData()
            }, completion: nil)
            self.makeNavigationBarButtons()
        }else{
        Apimanager.shared.stopAllSessions()
        let transition = CATransition()
        transition.duration = 0.4
        transition.type = "flip"
            DispatchQueue.main.async {
                Apimanager.shared.stopAllSessions()
                Utility.hideLoading()
                AWBanner.hide()
            }
        transition.subtype = kCATransitionFromLeft
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let projectsMapTab = sb.instantiateViewController(withIdentifier: "ListViewController") as! ProjectListViewController
        //self.navigationController?.pushViewController(projectsMapTab, animated: false)
        hideSearch()
        let projectsListTab = sb.instantiateViewController(withIdentifier: "ListViewController") as! ProjectListViewController
        if(locationManager.location != nil){
            projectsListTab.currentLocation =  locationManager.location!
        }else{
            projectsListTab.currentLocation = CLLocation.init(latitude:  38.904449, longitude: -77.046797)
        }
//        let projectsTabBarItem = UITabBarItem(title: "Projects", image: UIImage(named: "projects_empty"), selectedImage: UIImage(named: "projects_filled"))
//        projectsListTab.tabBarItem = projectsTabBarItem
        Apimanager.shared.stopAllSessions()
        projectsListTab.category = category
        projectsListTab.totalCount = totalCount
        Utility.hideToast()
        projectsListTab.selectedfilter = selectedfilter
        projectsListTab.certificationsarray = self.certificationsarray
        projectsListTab.ratingsarray = self.ratingsarray
        projectsListTab.versionsarray = self.versionsarray
        projectsListTab.countriesarray = self.countriesarray
        projectsListTab.queryingDistance = self.queryingDistance
        projectsListTab.statesarray = self.statesarray
        projectsListTab.currentPosition = self.mapView.camera
        projectsListTab.zoomLevel = Double(self.zoomLevel)
        if(self.locationManager.location != nil){
            projectsListTab.locationManager = self.locationManager
            projectsListTab.currentLocation = self.locationManager.location!
        }
        projectsListTab.filterProjects = [Project]()
        projectsListTab.projects = [Project]()
        projectsListTab.searchedProjects = [Project]()
        
//        if(isLarger == false){
//            projectsListTab.projects = self.projects
//            projectsListTab.totalCount = self.totalRecords
//            projectsListTab.totalRecords = self.totalRecords
//            projectsListTab.filterProjects = self.projects
//        }
        UserDefaults.standard.set(self.search.text!, forKey: "searchText")
        navigationController?.viewControllers[0] = projectsListTab
        self.navigationController?.view.setNeedsLayout()
        }
    }
    
    
    
    
    
    @objc func handleFilter(_ sender: Any){
        let viewController = ProjectFilterViewController()
        DispatchQueue.main.async {
            Apimanager.shared.stopAllSessions()
            Utility.hideLoading()
            AWBanner.hide()
        }
//        viewController.delegate = self
//        viewController.filter = category
//        viewController.totalCount = totalCount
//        viewController.selectedfilter = selectedfilter
//        viewController.certificationsarray = self.certificationsarray
//        viewController.ratingsarray = self.ratingsarray
//        viewController.versionsarray = self.versionsarray
//        viewController.countriesarray = self.countriesarray
//        viewController.statesarray = self.statesarray
//        viewController.tagarray = tagarray
        
        var vcArray = self.navigationController?.viewControllers
        //vcArray!.removeLast()
        vcArray!.append(viewController)
        //self.navigationController?.setViewControllers(vcArray!, animated: true)
        performSegue(withIdentifier: "Filterproject", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "Filterproject"){
            if let rootViewController = segue.destination as? UINavigationController {
                let viewController = rootViewController.topViewController as! ProjectFilterViewController
                viewController.delegate = self
                viewController.filter = category
                viewController.totalCount = totalCount
                viewController.selectedfilter = selectedfilter
                viewController.certificationsarray = self.certificationsarray
                viewController.ratingsarray = self.ratingsarray
                viewController.versionsarray = self.versionsarray
                viewController.countriesarray = self.countriesarray
                viewController.statesarray = self.statesarray
                viewController.tagarray = tagarray
            }
        }else if segue.identifier == "ProjectDetailsViewController" {
            if let vc = segue.destination as? UINavigationController {
                let v = vc.viewControllers[0] as! ProjectDetailsViewController
                if(frominfoView == true){
                    //Crash
                    print(sender as! GMSMarker)
                    if(self.markerArray.index(of: sender as! GMSMarker)! != -1){
                        v.node_id = self.projects[self.markerArray.index(of: sender as! GMSMarker)!].node_id
                        v.projectID = self.projects[self.markerArray.index(of: sender as! GMSMarker)!].ID
                        v.currentProject = self.projects[self.markerArray.index(of: sender as! GMSMarker)!]
                        v.navigationItem.title = ""
                    }
                }else{
                    
                    v.node_id = searchedProjects[sender as! Int].node_id
                    v.projectID = searchedProjects[sender as! Int].ID
                    v.currentProject = searchedProjects[sender as! Int]
                    v.navigationItem.title = ""
                }
                if(locationManager.location != nil){
                    self.currentLocation = locationManager.location
                }else{
                    self.currentLocation = CLLocation.init(latitude: 38.904449, longitude: -77.046797)
                }
                v.currentLocation = self.currentLocation
                //viewController.navigationItem.title = searchedProjects[sender as! Int].title
            }
        }
    }
    
    @objc func handleSearch(_ sender: Any){
        if(!searchOpen){
            showSearch()
        }else{
            hideSearch()
        }
    }
    
    @IBOutlet weak var mapViewTopConstraint: NSLayoutConstraint!
    func showSearch(){
        mapViewTopConstraint.constant = 64
        UIView.animate(withDuration: 1.0,
                       delay: 0.0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.0,
                       options: .curveEaseOut,
                       animations: {
                        self.view.layoutIfNeeded()
        }, completion: nil)
        searchOpen = true
    }
    
    func hideSearch(){
        mapViewTopConstraint.constant = 0
        UIView.animate(withDuration: 1.0,
                       delay: 0.0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.0,
                       options: .curveEaseIn,
                       animations: {
                        self.view.layoutIfNeeded()
        }, completion: nil)
        searchOpen = false
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        bounds = GMSCoordinateBounds()
        mapView.delegate = self
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        //useDownloadedData()
        closeDrawer()
        self.progressView.frame.origin.y = self.searchBar.frame.origin.y + self.searchBar.frame.size.height
        let tempcerts = certificationsarray.mutableCopy() as! NSMutableArray
        let tempratings = ratingsarray.mutableCopy() as! NSMutableArray
        let tempversions = versionsarray.mutableCopy() as! NSMutableArray
        let tempstate = statesarray.mutableCopy() as! NSMutableArray
        let tempcountry = countriesarray.mutableCopy() as! NSMutableArray
        tempcerts.remove("")
        tempratings.remove("")
        tempversions.remove("")
        tempstate.remove("")
        tempcountry.remove("")
        if((self.search.text?.count)! > 0){
            //self.search.becomeFirstResponder()
        }
        DispatchQueue.main.async {
            self.viewDidLayoutSubviews()
            if(tempcerts.count > 0 || tempratings.count > 0 || tempversions.count > 0 || tempstate.count > 0 || tempcountry.count > 0 || self.search.isFirstResponder){
                
                    //self.searchProjects()
            }else if(self.projects.count > 0){
                //self.mapView(self.mapView, idleAt: self.mapView.camera)
            }
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


extension ViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        mapView.isMyLocationEnabled = true
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            print(currentPosition.target.latitude)
            if(currentPosition.target.latitude != 0.0 &&  currentPosition.target.longitude != 0.0){
                self.mapView.animate(to: currentPosition)
            }else{
                mapView.animate(to: camera)
            }
        }
        locationManager.delegate = nil
        //self.loadProjectsElastic(search: self.searchText, category: self.category)
        print(location.coordinate.latitude,location.coordinate.longitude)
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            print("Location access was restricted.")
            let alertController = UIAlertController(title: "Accessing location recommended", message: "Get more accurate projects nearby by giving permissions to Explore. To allow that, Please go to Location -> While using the app", preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "Go to Settings", style: .default) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    })
                }
            }
            let cancelAction = UIAlertAction(title: "Continue anyway", style: .default){ (_) -> Void in
                self.mapView.settings.myLocationButton = false
                let position = GMSCameraPosition.camera(withLatitude: 38.904449,
                                                      longitude: -77.046797,
                                                      zoom: self.zoomLevel)
                self.mapView.animate(to: position)
            }
            alertController.addAction(cancelAction)
            alertController.addAction(settingsAction)
            self.present(alertController, animated: true, completion: nil)
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
            
        case .notDetermined:
            print("Not determined")
        case .authorizedAlways, .authorizedWhenInUse:
            print("Location status is OK.")
            if(currentPosition.target.latitude != 0.0 &&  currentPosition.target.longitude != 0.0){
                self.mapView.animate(to: currentPosition)
            }else{
                if(CLLocationManager.locationServicesEnabled()){
                    self.locationManager.delegate = self
                    self.locationManager.requestAlwaysAuthorization()
                    self.mapView?.isMyLocationEnabled = true
                    
                    //Location Manager code to fetch current location
                    self.locationManager.delegate = self
                    self.mapView.settings.myLocationButton = true
                    self.locationManager.startUpdatingLocation()
                }else{
                    print("Not allowed")
                }
            }
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
    
    func loadMapView(temp : [Project]){
        DispatchQueue.main.async
            {
                let registered_dot_pin = UIImage(named: "Registered_dot_pin")
                let certified_dot_pin = UIImage(named: "Certified_dot_pin")
                let silver_dot_pin = UIImage(named: "Silver_dot_pin")
                let gold_dot_pin = UIImage(named: "Gold_dot_pin")
                let platinum_dot_pin = UIImage(named: "Platinum_dot_pin")
                
                let registered_marker_pin = UIImage(named: "Registered_marker_pin")
                let certified_marker_pin = UIImage(named: "Certified_marker_pin")
                let silver_marker_pin = UIImage(named: "Silver_marker_pin")
                let gold_marker_pin = UIImage(named: "Gold_marker_pin")
                let platinum_marker_pin = UIImage(named: "Platinum_marker_pin")
                
                let registered_label_pin = UIImage(named: "Registered_label_pin")
                let certified_label_pin = UIImage(named: "Certified_label_pin")
                let silver_label_pin = UIImage(named: "Silver_label_pin")
                let gold_label_pin = UIImage(named: "Gold_label_pin")
                let platinum_label_pin = UIImage(named: "Platinum_label_pin")
                
                for i in 0 ..< temp.count {
                    let project = temp[i]
                // 2. Perform UI Operations.
                var position = CLLocationCoordinate2DMake(Double(project.lat)!,Double(project.long)!)
                var marker = GMSMarker(position: position)
                    let distanceinKms = Double(self.mapView.getRadius() * 0.000621371193 * 0.8)
                    if(distanceinKms > 201){
                        if(project.certification_date == "" || project.certification_level == ""){
                            marker.icon = registered_dot_pin
                        }else if(project.certification_level.lowercased() == "certified"){
                            marker.icon = certified_dot_pin
                        }else if(project.certification_level.lowercased() == "silver"){
                            marker.icon = silver_dot_pin
                        }else if(project.certification_level.lowercased() == "gold"){
                            marker.icon = gold_dot_pin
                        }else if(project.certification_level.lowercased() == "platinum"){
                            marker.icon = platinum_dot_pin
                        }
                    }else if(distanceinKms <= 200 && distanceinKms >= 2){
                        if(project.certification_date == "" || project.certification_level == ""){
                            marker.icon = registered_marker_pin
                        }else if(project.certification_level.lowercased() == "certified"){
                            marker.icon = certified_marker_pin
                        }else if(project.certification_level.lowercased() == "silver"){
                            marker.icon = silver_marker_pin
                        }else if(project.certification_level.lowercased() == "gold"){
                            marker.icon = gold_marker_pin
                        }else if(project.certification_level.lowercased() == "platinum"){
                            marker.icon = platinum_marker_pin
                        }
                    }
                    else if(distanceinKms < 2){
                        if(project.certification_date == ""){
                            marker.icon =   self.createImage("REGISTERED", image: registered_label_pin!)
                        }else if(project.certification_level.lowercased() == "certified"){
                            marker.icon =   self.createImage("CERTIFIED", image: certified_label_pin!)
                        }else if(project.certification_level.lowercased() == "silver"){
                            marker.icon = self.createImage("SILVER", image: silver_label_pin!)
                        }else if(project.certification_level.lowercased() == "gold"){
                            marker.icon = self.createImage("GOLD", image: gold_label_pin!)
                        }else if(project.certification_level.lowercased() == "platinum"){
                            marker.icon = self.createImage("PLATINUM", image: platinum_label_pin!)
                        }
                    }
                    //marker.icon = UIImage(named: "pin_new")
                    marker.title = project.title
                    marker.appearAnimation = GMSMarkerAnimation.none ;
                    marker.snippet = project.address.trimmingCharacters(in: .whitespacesAndNewlines)
                    marker.map = self.mapView
                    self.markerArray.append(marker)
                }
                if(self.totalRecords <= self.limit){
                    self.progressView.setProgress(Float(self.projects.count)/Float(self.totalRecords), animated: true)
                }else{
                    self.progressView.setProgress(Float(self.projects.count)/Float(self.limit), animated: true)
                }
                if(self.progressView.progress == 1.0){
                    self.progressView.isHidden = true
                }
        }
        
        /*var i = 0
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        renderer.delegate = self
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        if(mapView != nil){
            for project in projects{
                if(project.lat != " " && project.long != " " && project.lat != "0" && project.long != "0"){
                    let item = ClusterItem(position: CLLocationCoordinate2DMake(Double(project.lat)!, Double(project.long)!), index: i)
                    clusterManager?.add(item)
                    bounds = bounds?.includingCoordinate(CLLocationCoordinate2DMake(Double(project.lat)!, Double(project.long)!))
                    i += 1
                }
            }
            self.mapView.clear()
            clusterManager?.cluster()*/
            //mapView.animate(with: GMSCameraUpdate.fit(bounds!, withPadding: 30.0))
//        }else{
//            if(self.navigationController != nil){
//                Utility.showToast(y: self.navigationController!.navigationBar.frame.size.height, message: "Map not loaded, try again later!")
//            }
//        }
    }
    
    func createImage(_ label: String, image : UIImage) -> UIImage {
        //count is the integer that has to be shown on the marker
        let color = UIColor.white
        // select needed color
        let string = "\(label)"
        // the string to colorize
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        let attrs = [NSAttributedStringKey.foregroundColor: color, NSAttributedStringKey.paragraphStyle : paragraph, NSAttributedStringKey.font : UIFont.AktivGrotesk_Md(size: 9)]
        let attrStr = NSAttributedString(string: string, attributes: attrs)
        // add Font according to your need
        //let image = UIImage(named: "ic_marker_orange")!
        // The image on which text has to be added
        UIGraphicsBeginImageContextWithOptions(CGSize(width:70,height:20), false, 0.0)
        image.draw(in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(70), height: CGFloat(20)))
        let rect = CGRect(x: CGFloat(0), y: CGFloat(3), width: CGFloat(70), height: CGFloat(20))
        
        attrStr.draw(in: rect)
        
        let markerImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return markerImage
    }
    
    func createClusterImage(_ label: String, image : UIImage) -> UIImage {
        //count is the integer that has to be shown on the marker
        let color = UIColor.white
        // select needed color
        let string = "\(label)"
        // the string to colorize
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        let attrs = [NSAttributedStringKey.foregroundColor: color, NSAttributedStringKey.paragraphStyle : paragraph, NSAttributedStringKey.font : UIFont.AktivGrotesk_Md(size: 9)]
        let attrStr = NSAttributedString(string: string, attributes: attrs)
        // add Font according to your need
        //let image = UIImage(named: "ic_marker_orange")!
        // The image on which text has to be added
        UIGraphicsBeginImageContextWithOptions(CGSize(width:40,height:40), false, 0.0)
        
        let rect = CGRect(x: CGFloat(0), y: CGFloat(3), width: CGFloat(40), height: CGFloat(40))
        
        attrStr.draw(in: rect)
        
        let markerImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return markerImage
    }
    
    
    
    
    
    func setupClusters(){
        var i = 0
        self.mapView.clear()
         let iconGenerator = GMUDefaultClusterIconGenerator()
         let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
         let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
         renderer.delegate = self
         clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
         if(mapView != nil){
         for project in projects{
         if(project.lat != " " && project.long != " " && project.lat != "0" && project.long != "0"){
         let item = ClusterItem(position: CLLocationCoordinate2DMake(Double(project.lat)!, Double(project.long)!), index: i)
         clusterManager?.add(item)
         bounds = bounds?.includingCoordinate(CLLocationCoordinate2DMake(Double(project.lat)!, Double(project.long)!))
         i += 1
         }
         }
         self.mapView.clear()
         clusterManager?.cluster()
        }
//        mapView.animate(with: GMSCameraUpdate.fit(bounds!, withPadding: 30.0))
//                }else{
//                    if(self.navigationController != nil){
//                        Utility.showToast(y: self.navigationController!.navigationBar.frame.size.height, message: "Map not loaded, try again later!")
//                    }
//                }
    }
}

class ClusterItem: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var index: Int!
    
    init(position: CLLocationCoordinate2D, index: Int) {
        self.position = position
        self.index = index
    }
}


extension ViewController: GMUClusterManagerDelegate {
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
                                                 zoom: mapView.camera.zoom + 0.3)
        let update = GMSCameraUpdate.setCamera(newCamera)
        //mapView.moveCamera(update)
        return false
    }
}


extension ViewController : GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if(self.totalRecords <= self.limit){
            mapView.selectedMarker = marker;
            return true
        }
        if marker.userData is ClusterItem{
            return false
        }else if (marker.userData is GMUStaticCluster){
            mapView.animate(toZoom: mapView.camera.zoom + 2.0)
        }
        return false
    }
}

extension ViewController: GMUClusterRendererDelegate {
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker){
        DispatchQueue.main.async {
            if marker.userData is GMUCluster{
                    print("It is cluster")
                
            }else if marker.userData is ClusterItem{
                let project = self.projects[(marker.userData as! ClusterItem).index]
                if(self.projects.count > 0 && (marker.userData as! ClusterItem).index <= self.projects.count){
                    let registered_dot_pin = UIImage(named: "Registered_dot_pin")
                    let certified_dot_pin = UIImage(named: "Certified_dot_pin")
                    let silver_dot_pin = UIImage(named: "Silver_dot_pin")
                    let gold_dot_pin = UIImage(named: "Gold_dot_pin")
                    let platinum_dot_pin = UIImage(named: "Platinum_dot_pin")
                    
                    let registered_marker_pin = UIImage(named: "Registered_marker_pin")
                    let certified_marker_pin = UIImage(named: "Certified_marker_pin")
                    let silver_marker_pin = UIImage(named: "Silver_marker_pin")
                    let gold_marker_pin = UIImage(named: "Gold_marker_pin")
                    let platinum_marker_pin = UIImage(named: "Platinum_marker_pin")
                    
                    let registered_label_pin = UIImage(named: "Registered_label_pin")
                    let certified_label_pin = UIImage(named: "Certified_label_pin")
                    let silver_label_pin = UIImage(named: "Silver_label_pin")
                    let gold_label_pin = UIImage(named: "Gold_label_pin")
                    let platinum_label_pin = UIImage(named: "Platinum_label_pin")
                    let distanceinKms = Double(self.mapView.getRadius() * 0.000621371193 * 0.8)
                    if(distanceinKms > 201){
                        if(project.certification_date == "" || project.certification_level == ""){
                            marker.icon = registered_dot_pin
                        }else if(project.certification_level.lowercased() == "certified"){
                            marker.icon = certified_dot_pin
                        }else if(project.certification_level.lowercased() == "silver"){
                            marker.icon = silver_dot_pin
                        }else if(project.certification_level.lowercased() == "gold"){
                            marker.icon = gold_dot_pin
                        }else if(project.certification_level.lowercased() == "platinum"){
                            marker.icon = platinum_dot_pin
                        }
                    }else if(distanceinKms <= 200 && distanceinKms >= 2){
                        if(project.certification_date == "" || project.certification_level == ""){
                            marker.icon = registered_marker_pin
                        }else if(project.certification_level.lowercased() == "certified"){
                            marker.icon = certified_marker_pin
                        }else if(project.certification_level.lowercased() == "silver"){
                            marker.icon = silver_marker_pin
                        }else if(project.certification_level.lowercased() == "gold"){
                            marker.icon = gold_marker_pin
                        }else if(project.certification_level.lowercased() == "platinum"){
                            marker.icon = platinum_marker_pin
                        }
                    }
                    else if(distanceinKms < 2){
                        if(project.certification_date == ""){
                            marker.icon =   self.createImage("REGISTERED", image: registered_label_pin!)
                        }else if(project.certification_level.lowercased() == "certified"){
                            marker.icon =   self.createImage("CERTIFIED", image: certified_label_pin!)
                        }else if(project.certification_level.lowercased() == "silver"){
                            marker.icon = self.createImage("SILVER", image: silver_label_pin!)
                        }else if(project.certification_level.lowercased() == "gold"){
                            marker.icon = self.createImage("GOLD", image: gold_label_pin!)
                        }else if(project.certification_level.lowercased() == "platinum"){
                            marker.icon = self.createImage("PLATINUM", image: platinum_label_pin!)
                        }
                    }
                    marker.title = project.title
                    marker.snippet = project.address.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        }
    }
}

extension ViewController:  UICollectionViewDelegateFlowLayout {
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        frominfoView = true
        //print(self.projects[self.markerArray.index(of: marker)!].ID)
        //print(self.projects[self.markerArray.index(of: marker)!].certification_date)
        performSegue(withIdentifier: "ProjectDetailsViewController", sender: marker)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "exploreGridCell", for: indexPath) as! exploreGridCell
        cell.title.text = "\(categories[indexPath.row])"
        cell.counts.text = "\(indexPath.row) Projects"
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        cell.category_image.isUserInteractionEnabled = false
        if(categories[indexPath.row] == "Schools"){
                cell.category_image.setImage(UIImage.init(named: "school"), for: .normal)
        }else if(categories[indexPath.row] == "Offices"){
            cell.category_image.setImage(UIImage.init(named: "offices"), for: .normal)
        }else if(categories[indexPath.row] == "Retail"){
            cell.category_image.setImage(UIImage.init(named: "retail"), for: .normal)
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var bound = CGFloat(0)
        if(UIScreen.main.bounds.size.width < UIScreen.main.bounds.size.height){
           bound = UIScreen.main.bounds.size.width
        }else{
            bound = UIScreen.main.bounds.size.height
        }
        
        if ( UI_USER_INTERFACE_IDIOM() == .pad ){
            return CGSize(width: bound * 0.2, height: bound * 0.3)
        }
        
        return CGSize(width: bound * 0.42, height: bound * 0.5)
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if ( UI_USER_INTERFACE_IDIOM() == .pad ){
            return UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0)
        }
        return UIEdgeInsetsMake(20.0, 20.0, 0.0, 20.0)
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        if ( UI_USER_INTERFACE_IDIOM() == .pad ){
            return 20.0
        }
        return 20
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        var  bottomLeftCoord = mapView.projection.visibleRegion().nearLeft;
        var bottomRightCoord = mapView.projection.visibleRegion().nearRight;
        var distanceMetres = GMSGeometryDistance(bottomLeftCoord, bottomRightCoord)
        distanceMetres = distanceMetres *  0.000621371193 * 0.8
        print("Entered region", distanceMetres)
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {        
      //loadData()
        if(markerTapped == false){
        DispatchQueue.main.async {
        self.searchBar.resignFirstResponder()
            if((self.search.text?.count)! > 0){
                //self.search.becomeFirstResponder()
            }
        let distanceinKms = Double(self.mapView.getRadius() * 0.000621371193 * 0.8)
        //selff.currentPosition = self.mapView.camera
            if(distanceinKms <= 100){
                self.size = 400
            }else{
                self.size = 500
            }
            
            if(distanceinKms == distanceinKms){
                self.allDownloaded = true
                self.clusterManager?.clearItems()
                Apimanager.shared.stopAllSessions()
                self.mapView.clear()
                self.progressView.isHidden = false
                self.progressView.setProgress(0, animated: false)
                //Utility.hideToast()
            self.queryingDistance = distanceinKms
                self.mapView.clear()
            if(self.markerTapped == false){
            self.allDownloaded = false
            self.from = 0
                let iconGenerator = GMUDefaultClusterIconGenerator()
                let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
                let renderer = GMUDefaultClusterRenderer(mapView: self.mapView, clusterIconGenerator: iconGenerator)
                renderer.delegate = nil
            self.loadData()
            }else{
                self.markerTapped = false
            }
            }else{
                Utility.showToast(y: self.navigationController!.navigationBar.frame.size.height + self.searchBar.frame.size.height, message: "Please zoom in to view your results")
                self.allDownloaded = true
                Apimanager.shared.stopAllSessions()
                self.mapView.clear()
            }
            }
        }else{
            markerTapped = false
        }
    }
    
    
    
    
    
    func useDownloadedData(){
        DispatchQueue.main.async {
            Utility.hideLoading()
            Apimanager.shared.stopAllSessions()
        }
        
        var t = NSMutableArray()
        var a = AppDelegate()
        t = a.readFile()
        //        print(t)
        self.projects = [Project]()
        for i in t{
            if(self.projects.count < 50001){
                var dict = i as! NSDictionary
                var prj = Project()
                prj.address = dict["address"] as! String
                prj.certification_level = dict["certification_level"] as! String
                prj.country = dict["country"] as! String
                prj.node_id = dict["node_id"] as! String
                prj.lat = dict["lat"] as! String
                prj.long = dict["long"] as! String
                self.projects.append(prj)
            }else{
                t.removeAllObjects()
                DispatchQueue.main.async {
                    Utility.hideLoading()
                    
                }
                
                break
            }
        }
    }
    
    func loadData(){
        var  bottomLeftCoord = mapView.projection.visibleRegion().nearLeft;
        var bottomRightCoord = mapView.projection.visibleRegion().nearRight;
        var distanceMetres = GMSGeometryDistance(bottomLeftCoord, bottomRightCoord)
        distanceMetres = Double(self.mapView.getRadius() * 0.000621371193 * 0.8)
        let point = mapView.center;
        var  coordinate = self.mapView.projection.coordinate(for: point)
        if(locationManager.location != nil){
            let region = CLCircularRegion.init(center: coordinate, radius: distanceMetres, identifier: "myRegion")
            if(region.contains((locationManager.location?.coordinate)!)){
                coordinate = (locationManager.location?.coordinate)!
            }
        }
        DispatchQueue.main.async{
            Apimanager.shared.stopAllSessions()
            self.queryingLat = coordinate.latitude
            self.queryingLng = coordinate.longitude
            self.queryingDistance = distanceMetres
            self.allDownloaded = false
            self.from = 0
            self.mapView.clear()
            self.markerArray = [GMSMarker]()
            self.projects = [Project]()
            self.filterProjects = [Project]()
            self.tableView.reloadData()
            self.isLarger = false
            let tempcerts = self.certificationsarray.mutableCopy() as! NSMutableArray
            let tempratings = self.ratingsarray.mutableCopy() as! NSMutableArray
            let tempversions = self.versionsarray.mutableCopy() as! NSMutableArray
            let tempstate = self.statesarray.mutableCopy() as! NSMutableArray
            let tempcountry = self.countriesarray.mutableCopy() as! NSMutableArray
            tempcerts.remove("")
            tempratings.remove("")
            tempversions.remove("")
            tempstate.remove("")
            tempcountry.remove("")
            //if(self.search.text?.count == 0 && tempcerts.count == 0 && tempratings.count == 0 && tempversions.count == 0 && tempstate.count == 0 && tempcountry.count == 0 ){
            if(self.tableViewtopConstraint.constant != 0){
                let distanceinKms = Double(self.mapView.getRadius() * 0.000621371193 * 0.8)
                self.loadProjectsElasticUsingLocation(search: self.search.text!, category: self.category, lat: self.mapView.camera.target.latitude, lng: self.mapView.camera.target.longitude, distance: distanceinKms)
            }else{
                self.searchProjectUsingLocation(search: self.search.text!, category: self.category, lat: coordinate.latitude , lng: coordinate.longitude, distance: distanceMetres)
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Select")
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let exploreViewController = sb.instantiateViewController(withIdentifier: "exploreViewController") as! exploreViewController
        exploreViewController.category = categories[indexPath.row]
        var viewcontrollers = self.navigationController?.viewControllers as! [UIViewController]
        viewcontrollers.append(exploreViewController)
        self.navigationController?.setViewControllers(viewcontrollers, animated: true)
    }
    
    
    
    
    
}

extension ViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.allDownloaded = true
        Apimanager.shared.stopAllSessions()
        self.filterProjects = [Project]()
        self.searchedProjects = [Project]()
        
        self.tableView.reloadData()
        if(searchBar.tag == 23){
            DispatchQueue.main.async {

                self.progressView.isHidden = true
                    self.allDownloaded = true
                    Apimanager.shared.stopAllSessions()
                    self.filterProjects = [Project]()
                    self.searchedProjects = [Project]()
                    
                    self.tableView.reloadData()
                    self.tableViewContainer.isHidden = false
                    self.tableViewtopConstraint.constant = 0
                    self.search.becomeFirstResponder()
                    UIView.animate(withDuration: 0.2,
                                   delay: 0.0,
                                   usingSpringWithDamping: 0.2,
                                   initialSpringVelocity: 0.0,
                                   options: .curveEaseOut,
                                   animations: {
                                    //self.view.layoutIfNeeded()
                                    //self.tableView.reloadData()
                    }, completion: { (finished: Bool) in
                        self.search.becomeFirstResponder()
                    })
                //self.searchBar.isHidden = true
                Utility.hideToast()
                if(self.locationManager.location != nil){
                    self.currentLocation = self.locationManager.location
                }else{
                    self.currentLocation = CLLocation.init(latitude: 38.904449, longitude: -77.046797)
                }
                
                if(self.isLarger == true){
                    
                }
                
                
                //self.searchBar.resignFirstResponder()
                self.selected_searchbar = "searchcontroller"
                searchBar.becomeFirstResponder()
                self.tableView.isHidden = false
                self.slideUpView.isHidden = true
                self.from = 0
                self.searchProjects()
                
            }
        }else{
            self.tableViewContainer.isHidden = true
        }
        return true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let attributes = [NSAttributedStringKey.foregroundColor : self.tabBarController?.tabBar.tintColor]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
        searchBar.tintColor = .darkGray
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = .black
       searchBar.showsCancelButton = true
        for subview in searchBar.subviews {
            for innerSubview in subview.subviews {
                if innerSubview is UITextField {
                    innerSubview.backgroundColor = UIColor(red:0.945, green:0.945, blue:0.945, alpha:1.0)
                    break
                }
            }
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
       searchBar.showsCancelButton = false
        for subview in searchBar.subviews {
            for innerSubview in subview.subviews {
                if innerSubview is UITextField {
                    innerSubview.backgroundColor = UIColor(red:1, green:1, blue:1, alpha:1.0)
                    break
                }
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        for subview in searchBar.subviews {
            for innerSubview in subview.subviews {
                if innerSubview is UITextField {
                    innerSubview.backgroundColor = UIColor(red:1, green:1, blue:1, alpha:1.0)
                    break
                }
            }
        }
        if(searchBar.tag == 23){
            DispatchQueue.main.async {
                 self.searchBar.isHidden = false
                self.tableViewContainer.isHidden = true
                searchBar.text = ""
                self.searchText = ""
                self.filterProjects = [Project]()
                self.searchedProjects = [Project]()
                self.tableView.reloadData()
                self.mapView.clear()
                Apimanager.shared.stopAllSessions()
                self.tableViewtopConstraint.constant = 0.58 * UIScreen.main.bounds.size.height
                UserDefaults.standard.set(searchBar.text!, forKey: "searchText")
                self.makeNavigationBarButtons()
                self.mapView(self.mapView, idleAt: self.mapView.camera)
                //self.loadData()
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if(searchBar == self.searchBar){
        
        let searchTxt = searchBar.text!
        request.naturalLanguageQuery = searchTxt
        
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            
            for i in response.mapItems{
                i.placemark.coordinate.latitude
            }
            
            if(response.mapItems.count == 0){
                print("Not found")
            }else{
                let position = GMSCameraPosition.camera(withLatitude: response.mapItems.first!.placemark.coordinate.latitude,
                                                      longitude: response.mapItems.first!.placemark.coordinate.longitude,
                                                      zoom: 16)
                self.mapView.animate(to: position)
                
            }
        }
        }else{
            if((self.search.text?.count)! > 0){
                if(UIDevice.current.userInterfaceIdiom == .phone){
                arrFilter.removeAll(keepingCapacity: false)
                self.arrCountry.removeAll()
                arrProjects = [String]()
                let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", search.text!)
                let array = (arrCountry as NSArray).filtered(using: searchPredicate)
                self.arrProjects = [String]()
                arrFilter = array as! [String]
                    timer.invalidate()
                UserDefaults.standard.set(searchBar.text!, forKey: "searchText")
                    Apimanager.shared.stopAllSessions()
                searchBar.resignFirstResponder()
                searchBar.showsCancelButton = false
                    timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(searchProjects), userInfo: nil, repeats: false)
                }
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchTxt: String) {
        if(searchBar == self.search){
            arrFilter.removeAll(keepingCapacity: false)
            self.arrCountry.removeAll()
            arrProjects = [String]()
            let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", search.text!)
            let array = (arrCountry as NSArray).filtered(using: searchPredicate)
            self.arrProjects = [String]()
            arrFilter = array as! [String]
            timer.invalidate()
            UserDefaults.standard.set(searchBar.text!, forKey: "searchText")
            Apimanager.shared.stopAllSessions()
            if(searchBar.text?.count == 0){
                searchBar.resignFirstResponder()
                self.tableViewContainer.isHidden = true
            }
            timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(searchProjects), userInfo: nil, repeats: false)
        }
        
    }
    
}

extension GMSMapView {
    func getCenterCoordinate() -> CLLocationCoordinate2D {
        let centerPoint = self.center
        let centerCoordinate = self.projection.coordinate(for: centerPoint)
        return centerCoordinate
    }
    
    func getTopCenterCoordinate() -> CLLocationCoordinate2D {
        // to get coordinate from CGPoint of your map
        let topCenterCoor = self.convert(CGPoint(x: self.frame.size.width, y: 0), from: self)
        let point = self.projection.coordinate(for: topCenterCoor)
        return point
    }
    
    func getRadius() -> CLLocationDistance {
        let centerCoordinate = getCenterCoordinate()
        let centerLocation = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
        let topCenterCoordinate = self.getTopCenterCoordinate()
        let topCenterLocation = CLLocation(latitude: topCenterCoordinate.latitude, longitude: topCenterCoordinate.longitude)
        let radius = CLLocationDistance(centerLocation.distance(from: topCenterLocation))
        return round(radius)
    }
}


extension UISearchBar{
    var textField : UITextField{
        return self.value(forKey: "_searchField") as! UITextField
    }
}
