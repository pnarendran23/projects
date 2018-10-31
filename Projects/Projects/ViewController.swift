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
    fileprivate var loading = false
    var frominfoView = false
    var isLarger = false
    var markerArray = [GMSMarker]()
    fileprivate var loadType = "init"
    var filterProjects = [Project]()
    fileprivate var pageNumber = 0
    var searchedProjects = [Project]()
    var markerTapped = false
    var size = 150
    var allDownloaded = false
    var from = 0
    @IBOutlet weak var arrowimage: UIImageView!
    var selected_searchbar = ""
    
    override func viewWillDisappear(_ animated: Bool) {
        Apimanager.shared.stopAllSessions()
        Utility.hideToast()
        self.view.endEditing(true)
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
                if(tempcerts.count > 0 || tempratings.count > 0 || tempversions.count > 0 || tempstate.count > 0 || tempcountry.count > 0){
                    CATransaction.begin()
                    CATransaction.setValue(2.0, forKey: kCATransactionAnimationDuration)
                    let camera = GMSCameraPosition.camera(withLatitude: self.mapView.camera.target.latitude , longitude: self.mapView.camera.target.longitude, zoom: 8)
                    self.mapView.camera = camera
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
    
    var searchController = UISearchController()
    
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
            self.searchProjectUsingLocation(search: self.searchController.searchBar.text!, category: self.category, lat: self.queryingLat, lng: self.queryingLng, distance: self.queryingDistance)
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
                        Utility.showToast(y: self.navigationController!.navigationBar.frame.size.height, message: "Something went wrong")
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
            self.makeNavigationBarButtons()
        Apimanager.shared.getProjectsElasticForMapNew (from: self.from, sizee : size, search : search, category : dict, lat : lat, lng : lng, distance : distance, callback: {(totalRecords, projects, code) in
            if(code == -1 && projects != nil){
                self.totalRecords = totalRecords!
                self.projects.append(contentsOf: projects!)
                self.searchedProjects = self.projects
                //self.lastRecordsCount = projects!.count
                //self.filterProjects = self.projects
                DispatchQueue.main.async {
                    Utility.hideLoading()
                    self.arrProjects = [String]()
                    self.arrFilter = [String]()
                    self.arrCountry = [String]()
                    if(CLLocationManager.locationServicesEnabled()){
                        
                        if(self.from == 0 && totalRecords! == 0){
                            self.loadMapView(temp: projects!)
                        }else{
                                if(projects!.count > 0 && self.projects.count <= 2000){
                                self.from = self.from + self.size
                                self.isLarger = false
                                    Utility.hideToast()
                                self.loadMapView(temp: projects!)
                            self.loadProjectsElasticUsingLocation(search: search, category: category, lat: lat , lng: lng, distance: distance)
                            }else{
//                                if(totalRecords! > 500){
//                                    let temp = self.searchedProjects.first as! Project
//                                    var temparray = [Project]()
//                                    var maxValue = 0
//                                    if(totalRecords! > 500 && totalRecords! <= 999){
//                                        maxValue = 500
//                                    }else if(totalRecords! > 1000){
//                                        maxValue = 1000
//                                    }
//                                    for i in 0...maxValue{
//                                        temparray.append(temp)
//                                    }
//                                    self.isLarger = true
//                                    self.projects = temparray
//                                    self.searchedProjects = temparray
//                                    self.loadMapView()
//                                }
                                    self.tableView.reloadData()
                                self.allDownloaded = true
                            }
                        }
                    }else{
                        self.isLarger = false
                        self.allDownloaded = false
                        print("Not allowed")
                    }
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
                        Utility.showToast(y: self.navigationController!.navigationBar.frame.size.height, message: "Something went wrong")
                    }
                }
                
            }
        })
        }
    }
    
    
    func searchProjectUsingLocation(search: String, category: String, lat : Double, lng : Double, distance : Double){
        //sizee was 500000
        var dict = [[String : Any]]()
        dict = constructCategory()
        self.navigationItem.rightBarButtonItems = nil
        self.makeNavigationBarButtons()
            Apimanager.shared.searchProjectsElasticForMapNew (from: 0, sizee : size, search : search, category : dict, callback: {(totalRecords, projects, code) in
                if(code == -1 && projects != nil){
                    DispatchQueue.main.async {
                    self.searchedProjects = projects!
                    self.totalRecords = totalRecords!
                    //self.lastRecordsCount = projects!.count
                    self.filterProjects = self.projects
                    self.projects = self.searchedProjects
                    self.loadMapView(temp: projects!)
                    Utility.hideLoading()
                        self.arrProjects = [String]()
                        self.arrFilter = [String]()
                        self.isLarger = false
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
    
    var locationsearchTxt = ""
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (self.searchController.isActive) {
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
            
            self.searchController.searchBar.resignFirstResponder()
        }else{
            let camera = GMSCameraPosition.camera(withLatitude: (locationManager.location?.coordinate.latitude)! ,
                                                  longitude: (locationManager.location?.coordinate.longitude)!,
                                                  zoom: zoomLevel)
            mapView.animate(to: camera)
            self.searchBar.resignFirstResponder()
        }
        
        if(indexPath.row > 0){
            if (self.searchController.isActive) {
            } else {
                locationsearchTxt = arrCountry[indexPath.row]
            }
        }else{
            if(!self.searchController.isActive){
                locationsearchTxt = ""
            }
        }
        //self.tableView.isHidden = true
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    //MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.searchController.isActive) {
            return self.searchedProjects.count
        } else {
            return self.arrCountry.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(!self.searchController.isActive && indexPath.row == 0){
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "locationcell", for: indexPath) as! locationcell
            return cell1
        }else{
            let project = searchedProjects[indexPath.row]
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
                if(tempLocation!.distance(from: locationManager.location!)/1609.34 < 1000){
                    distance = "\(Double(round(tempLocation!.distance(from: locationManager.location!)/1609.34 * 100)/100)) m. away"
                }else{
                    distance = "1000+ mi. away"
                }
                var boldText = "\n\(project.state), \(project.country)\n\(distance)"
                var mutableParagraphStyle = NSMutableParagraphStyle()
                
                // *** set LineSpacing property in points ***
                mutableParagraphStyle.lineSpacing = 4 // Whatever line spacing you want in points
                //bold.addAttribute(NSAttributedStringKey.paragraphStyle , value: mutableParagraphStyle, range: NSMakeRange(0, boldText.count))
                
                
                let attrs = [NSAttributedStringKey.font : cell.address.font] as [NSAttributedStringKey : Any]
                var boldString = NSMutableAttributedString(string: boldText, attributes:attrs)
                boldString.addAttribute(NSAttributedStringKey.paragraphStyle , value: mutableParagraphStyle, range: NSMakeRange(0, boldText.count))
                cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 14)
                
                boldString.addAttribute(NSAttributedStringKey.foregroundColor , value: UIColor(red:0.53, green:0.60, blue:0.64, alpha:1.0), range: NSMakeRange("\n\(project.state), \(project.country)".count, distance.count + 1))
                
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
                
                //cell.project_image.sd_setImage(with: URL(string: project.image), placeholderImage: UIImage.init(named: "project_placeholder"))
                
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCellwithoutImage", for: indexPath) as! ProjectCellwithoutImage
                //cell.address.text = "\(project.address.replacingOccurrences(of: "\n", with: ""))"
                let normalText  = "\(project.title)"
                
                let attributedString = NSMutableAttributedString(string:normalText)
                
                var distance = ""
                if(tempLocation!.distance(from: locationManager.location!)/1609.34 < 1000){
                    distance = "\(Double(round(tempLocation!.distance(from: locationManager.location!)/1609.34 * 100)/100)) mi. away"
                }else{
                    distance = "1000+ mi. away"
                }
                cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 14)
                var boldText = "\n\(project.state), \(project.country)\n\(distance)"
                var mutableParagraphStyle = NSMutableParagraphStyle()
                
                // *** set LineSpacing property in points ***
                mutableParagraphStyle.lineSpacing = 4 // Whatever line spacing you want in points
                //bold.addAttribute(NSAttributedStringKey.paragraphStyle , value: mutableParagraphStyle, range: NSMakeRange(0, boldText.count))
                
                
                let attrs = [NSAttributedStringKey.font : cell.address.font] as [NSAttributedStringKey : Any]
                var boldString = NSMutableAttributedString(string: boldText, attributes:attrs)
                boldString.addAttribute(NSAttributedStringKey.paragraphStyle , value: mutableParagraphStyle, range: NSMakeRange(0, boldText.count))
                
                
                boldString.addAttribute(NSAttributedStringKey.foregroundColor , value: UIColor(red:0.53, green:0.60, blue:0.64, alpha:1.0), range: NSMakeRange("\n\(project.state), \(project.country)".count, distance.count + 1))
                
                attributedString.append(boldString)
                cell.projectname.attributedText = attributedString
                //cell.projectname.attributedText = "\(project.title)\n\(project.address.replacingOccurrences(of: "\n", with: ""))"
                
                return cell
            }
        }
        
    }
    
    func configureCell(cell: UITableViewCell, forRowAtIndexPath: IndexPath) {
        // 3
        if ((self.searchController.isActive || mapViewTopConstraint.constant == 0) && arrFilter.count > 0) {
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
                        
                        self.view.layoutIfNeeded()
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
                        self.view.layoutIfNeeded()
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
        DispatchQueue.main.async {
            self.tableView.isHidden = false
            Utility.hideToast()
            if(self.locationManager.location != nil){
                self.currentLocation = self.locationManager.location
            }else{
                self.currentLocation = CLLocation.init(latitude: 38.904449, longitude: -77.046797)
            }
         
            if(self.isLarger == true){
                self.searchedProjects = [Project]()
                self.projects = [Project]()
            }
            
            if(self.searchController.searchBar.text?.count == 0){
                self.arrFilter = [String]()
                self.arrCountry = [String]()
                
                self.tableView.reloadData()
            }
            Apimanager.shared.stopAllSessions()
            self.searchBar.resignFirstResponder()
            self.selected_searchbar = "searchcontroller"
            self.slideUpView.isHidden = true
            self.filterProjects = [Project]()
            self.arrCountry = [String]()
            self.searchedProjects = [Project]()
            self.tableView.reloadData()
            self.totalRecords = 0
            self.from = 0
            self.searchProjects()
            
        }
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {        
        self.tableView.isHidden = true
        DispatchQueue.main.async {
            self.makeNavigationBarButtons()
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
                self.size = 500
                self.markerArray = [GMSMarker]()
                self.projects = [Project]()
                self.isLarger = false
                self.loadProjectsElasticUsingLocation(search: searchController.searchBar.text!, category: "All", lat: self.queryingLat, lng: self.queryingLng, distance: distanceinKms)
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
        (cell as? ListHeader)?.projects.text = "Projects"
        if(self.totalRecords <= 1){
            (cell as? ListHeader)?.rightside.text = "\(self.totalRecords) Result"
        }else{
            (cell as? ListHeader)?.rightside.text = "\(self.totalRecords) Results"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView.init(frame: .zero)
        self.searchBar.layer.borderColor = searchBar.barTintColor?.cgColor
        for family in UIFont.familyNames {
            print("\(family)")
            
            for name in UIFont.fontNames(forFamilyName: family) {
                print("   \(name)")
            }
        }
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableViewAutomaticDimension
        slideUpView.isHidden = true
        tableView.register(UINib.init(nibName:"locationcell", bundle: nil), forCellReuseIdentifier: "locationcell")
        collectionView.register(UINib.init(nibName: "moreCollectionsView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "moreCollectionsView")
        
        tableView.register(UINib(nibName: "ProjectCellwithImage", bundle: nil), forCellReuseIdentifier: "ProjectCellwithImage")
        tableView.register(UINib(nibName: "ProjectCellwithoutImage", bundle: nil), forCellReuseIdentifier: "ProjectCellwithoutImage")
        tableView.register(UINib(nibName: "ListHeader", bundle: nil), forCellReuseIdentifier: "ListHeader")
        
        self.searchBar.delegate = self
        self.tableView.isHidden = true
        // Do any additional setup after loading the view, typically from a nib.
        self.searchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchBar.searchBarStyle = .minimal
            controller.dimsBackgroundDuringPresentation = false
            controller.searchResultsUpdater = self
            controller.searchBar.showsCancelButton = false
            controller.searchBar.sizeToFit()
            if(UserDefaults.standard.object(forKey: "searchText") != nil){
                controller.searchBar.text = UserDefaults.standard.object(forKey: "searchText") as! String
            }
            controller.searchBar.delegate = self
            controller.searchBar.showsScopeBar = true
            (controller.searchBar.value(forKey: "searchField") as? UITextField)?.font = UIFont.AktivGrotesk_Md(size: 14)
            controller.hidesNavigationBarDuringPresentation = false;
            controller.searchBar.searchBarStyle = .minimal;
            controller.searchBar.barTintColor = UIColor.white
            controller.searchBar.barTintColor = UIColor.white
            controller.searchBar.searchBarStyle = .default
            controller.searchBar.isTranslucent = true
            controller.searchBar.searchFieldBackgroundPositionAdjustment = UIOffset(horizontal: -13, vertical: 0)
            return controller
        })()
        
        searchBar.textField.clearButtonMode = .never
        self.searchController.searchBar.textField.clearButtonMode = .never
        
        (self.searchBar.value(forKey: "searchField") as? UITextField)?.font = UIFont.AktivGrotesk_Md(size: 14)
        
        
        self.searchController.delegate = self
        
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        // Include the search bar within the navigation bar.
        self.navigationItem.titleView = self.searchController.searchBar;
        
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
        self.view.layoutIfNeeded()
        //self.navigationController?.navigationBar.isTranslucent = true
        //searchBar.barTintColor = UIColor.hex(hex: Colors.primaryColor)
        searchBar.layer.borderWidth = 1
        self.navigationController?.navigationBar.barTintColor = UIColor.white        
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
        listButton.setImage(UIImage(named: "ListView_BU"), for: .normal)
        listButton.imageView?.contentMode = .scaleAspectFit
        listButton.addTarget(self, action:#selector(self.handleList(_:)), for: .touchUpInside)
        let listBarButton = UIBarButtonItem(customView: listButton)
        
        
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white] as [AnyHashable : NSObject]
        //[NSAttributedStringKey.foregroundColor:UIColor.white, kCTFontAttributeName : UIFont.gothamBook(size: 18) ] as [AnyHashable : NSObject]
        navigationController?.navigationBar.titleTextAttributes = textAttributes as! [NSAttributedStringKey : Any]
        self.navigationItem.title = "Projects"
        self.navigationItem.rightBarButtonItems = [listBarButton, filterBarButton]
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
    }
    
    @objc func handleList(_ sender: Any){
        Apimanager.shared.stopAllSessions()
        let transition = CATransition()
        transition.duration = 0.4
        transition.type = "flip"
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
        projectsListTab.filterProjects = [Project]()
        projectsListTab.projects = [Project]()
        self.searchController.delegate = nil
//        if(isLarger == false){
//            projectsListTab.projects = self.projects
//            projectsListTab.totalCount = self.totalRecords
//            projectsListTab.totalRecords = self.totalRecords
//            projectsListTab.filterProjects = self.projects
//        }
        UserDefaults.standard.set(self.searchController.searchBar.text!, forKey: "searchText")
        navigationController?.viewControllers[0] = projectsListTab
    }
    
    
    
    @objc func handleFilter(_ sender: Any){
        let viewController = ProjectFilterViewController()
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
            if let vc = segue.destination as? ProjectDetailsViewController {
                if(frominfoView == true){
                    //Crash
                    vc.node_id = self.projects[self.markerArray.index(of: sender as! GMSMarker)!].node_id
                    vc.projectID = self.projects[self.markerArray.index(of: sender as! GMSMarker)!].ID
                    vc.currentProject = self.projects[self.markerArray.index(of: sender as! GMSMarker)!]
                    vc.navigationItem.title = vc.currentProject.title
                }else{
                    
                    vc.node_id = searchedProjects[sender as! Int].node_id
                    vc.projectID = searchedProjects[sender as! Int].ID
                    vc.currentProject = searchedProjects[sender as! Int]
                    vc.navigationItem.title = vc.currentProject.title
                }
                if(locationManager.location != nil){
                    self.currentLocation = locationManager.location
                }else{
                    self.currentLocation = CLLocation.init(latitude: 38.904449, longitude: -77.046797)
                }
                vc.currentLocation = self.currentLocation
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
        //useDownloadedData()
        closeDrawer()
        if(!allDownloaded){
            allDownloaded = !allDownloaded
            loadData()
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
                for project in self.projects{
                // 2. Perform UI Operations.
                var position = CLLocationCoordinate2DMake(Double(project.lat)!,Double(project.long)!)
                var marker = GMSMarker(position: position)
                    marker.icon = UIImage(named: "pin_new")
                    marker.title = project.title
                    marker.appearAnimation = GMSMarkerAnimation.pop ;
                    marker.snippet = project.address.trimmingCharacters(in: .whitespacesAndNewlines)
                    marker.map = self.mapView
                    self.markerArray.append(marker)
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
        mapView.moveCamera(update)
        return false
    }
}


extension ViewController : GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapView.selectedMarker = marker;
        return true
    }
}

extension ViewController: GMUClusterRendererDelegate {
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker){
        DispatchQueue.main.async {
            if marker.userData is ClusterItem{
                if(self.projects.count > 0 && (marker.userData as! ClusterItem).index <= self.projects.count){
                    marker.icon = UIImage(named: "pin")
                    marker.title = self.projects[(marker.userData as! ClusterItem).index].title
                    marker.snippet = self.projects[(marker.userData as! ClusterItem).index].address.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        frominfoView = true
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.backgroundColor = tabbar.barTintColor
        tabbar.invalidateIntrinsicContentSize()
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
        let distanceinKms = Double(self.mapView.getRadius() * 0.000621371193 * 0.8)
        //self.currentPosition = self.mapView.camera
            if(distanceinKms <= 2500){
                Utility.hideToast()
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
            self.size = 500
            self.markerArray = [GMSMarker]()
            self.projects = [Project]()
            self.isLarger = false
            if(self.searchController.searchBar.text?.count == 0){
                self.loadProjectsElasticUsingLocation(search: self.searchController.searchBar.text!, category: self.category, lat: coordinate.latitude , lng: coordinate.longitude, distance: distanceMetres)
            }else{
                self.searchProjectUsingLocation(search: self.searchController.searchBar.text!, category: self.category, lat: coordinate.latitude , lng: coordinate.longitude, distance: distanceMetres)
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
        self.filterProjects = [Project]()
        self.arrCountry = [String]()
        self.searchedProjects = [Project]()
        self.tableView.reloadData()
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
            if((searchController.searchBar.text?.count)! > 0){
                arrFilter.removeAll(keepingCapacity: false)
                self.arrCountry.removeAll()
                arrProjects = [String]()
                let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
                let array = (arrCountry as NSArray).filtered(using: searchPredicate)
                self.arrProjects = [String]()
                arrFilter = array as! [String]
                
                if(searchController.isActive){
                    timer.invalidate()
                    Apimanager.shared.stopAllSessions()
                    timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(searchProjects), userInfo: nil, repeats: false)
                }
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchTxt: String) {
        
       
        
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
