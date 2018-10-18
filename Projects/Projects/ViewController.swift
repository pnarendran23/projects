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
import MapKit

class ViewController: UIViewController,UIGestureRecognizerDelegate, UITabBarDelegate,UISearchResultsUpdating, UITableViewDelegate,UITableViewDataSource, ProjectFilterDelegate, UISearchControllerDelegate {
    var request = MKLocalSearchRequest()
    fileprivate var loading = false
    fileprivate var loadType = "init"
    var filterProjects = [Project]()
    fileprivate var pageNumber = 0
    var searchedProjects = [Project]()
    var markerTapped = false
    var size = 500
    var allDownloaded = false
    var from = 0
    @IBOutlet weak var arrowimage: UIImageView!
    var selected_searchbar = ""
    
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
            self.loadData()
            //loadProjects(category: category, search: searchText, page: pageNumber, loadType: loadType)
            //loadProjectsWithPagination(filterChanged: filterChanged, id: self.scrollId, category: category, loadType: loadType)
            DispatchQueue.main.async {
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
            arrFilter.removeAll(keepingCapacity: false)
            self.arrCountry.removeAll()
            arrProjects = [String]()
            let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
            let array = (arrCountry as NSArray).filtered(using: searchPredicate)
            self.arrProjects = [String]()
            arrFilter = array as! [String]
            self.navigationItem.rightBarButtonItems = nil
            timer.invalidate()
            Apimanager.shared.stopAllSessions()
            timer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(searchProjects), userInfo: nil, repeats: false)
            
            //self.tableView.reloadData()
    }
    
    
    @objc func searchProjects(){
        
        var  bottomLeftCoord = mapView.projection.visibleRegion().nearLeft;
        var bottomRightCoord = mapView.projection.visibleRegion().nearRight;
        
        let point = mapView.center;
        var coor = self.mapView.projection.coordinate(for: point)
        
        
        var distanceMetres = GMSGeometryDistance(bottomLeftCoord, bottomRightCoord)
        distanceMetres = distanceMetres/1000
        queryingDistance = distanceMetres
        filterProjects = [Project]()
        coor = self.mapView.projection.coordinate(for: point)
        if(locationManager.location != nil){
            let region = CLCircularRegion.init(center: coor, radius: distanceMetres * 1000, identifier: "myRegion")
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
                    self.loadMapView()
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
    
    func constructCategory() -> [[String : [String : String]]]{
        var dict = [[String : [String : String]]]()
        for i in certificationsarray{
            if(i as! String != ""){
                dict.append([ "match" : [ "certification_level" : i as! String ]])
            }
        }
        for i in countriesarray{
            if(i as! String != ""){
                dict.append([ "match" : [ "country" : i as! String ]])
            }
        }
        
        for i in statesarray{
            if(i as! String != ""){
                dict.append([ "match" : [ "state" : i as! String ]])
            }
        }
        
        for i in ratingsarray{
            if(i as! String != ""){
                dict.append([ "match" : [ "rating_system" : i as! String ]])
            }
        }
        
        for i in versionsarray{
            if(i as! String != ""){
                dict.append([ "match" : [ "rating_system_version" : i as! String ]])
            }
        }
        return dict
    }
    
    
    func loadProjectsElasticUsingLocation(search: String, category: String, lat : Double, lng : Double, distance : Double){
        //sizee was 500000
        
        if(!allDownloaded){
            var dict = [[String : [String : String]]]()
            dict = constructCategory()
        Apimanager.shared.getProjectsElasticForMapNew (from: self.from, sizee : size, search : search, category : dict, lat : lat, lng : lng, distance : distance, callback: {(totalRecords, projects, code) in
            if(code == -1 && projects != nil){
                //self.totalRecords = totalRecords!
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
                        if(projects!.count > 0 && totalRecords! <= 50000){
                            self.from = self.from + self.size
                            self.loadMapView()
                        self.loadProjectsElasticUsingLocation(search: search, category: category, lat: lat , lng: lng, distance: distance)
                        }else{
                            self.allDownloaded = true
                        }
                    }else{
                        print("Not allowed")
                    }
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
    }
    
    
    func searchProjectUsingLocation(search: String, category: String, lat : Double, lng : Double, distance : Double){
        //sizee was 500000
        var dict = [[String : [String : String]]]()
        dict = constructCategory()
            Apimanager.shared.getProjectsElasticForMapNew (from: 0, sizee : 1000, search : search, category : dict, lat : lat, lng : lng, distance : distance, callback: {(totalRecords, projects, code) in
                if(code == -1 && projects != nil){
                    self.searchedProjects = projects!
                    //self.totalRecords = totalRecords!
                    //self.lastRecordsCount = projects!.count
                    //self.filterProjects = self.projects
                    DispatchQueue.main.async {
                        Utility.hideLoading()
                        self.arrProjects = [String]()
                        self.arrFilter = [String]()
                        if(CLLocationManager.locationServicesEnabled()){                            
                            self.tableView.reloadData()
                        }else{
                            print("Not allowed")
                        }
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
                
                let boldText = "\n\(project.address.replacingOccurrences(of: "\n", with: ""))"
                
                
                let attrs = [NSAttributedStringKey.font : cell.address.font, NSAttributedStringKey.foregroundColor : UIColor.lightGray] as [NSAttributedStringKey : Any]
                let boldString = NSMutableAttributedString(string: boldText, attributes:attrs)
                attributedString.append(boldString)
                cell.projectname.attributedText = attributedString
                //cell.address.text = "\(project.address.replacingOccurrences(of: "\n", with: ""))"
                cell.project_image.sd_setImage(with: URL(string: project.image), placeholderImage: UIImage.init(named: "project_placeholder"))
                if(tempLocation!.distance(from: locationManager.location!) * 0.000621371192 < 1000){
                    cell.distance.text = "\(Double(round(tempLocation!.distance(from: currentLocation!) * 0.000621371192 * 100) / 100)) mi."
                }else{
                    cell.distance.text = "1000+ mi."
                }
                cell.accessoryType = .disclosureIndicator
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCellwithoutImage", for: indexPath) as! ProjectCellwithoutImage
                //cell.address.text = "\(project.address.replacingOccurrences(of: "\n", with: ""))"
                let normalText  = "\(project.title)"
                
                let attributedString = NSMutableAttributedString(string:normalText)
                
                let boldText = "\n\(project.address.replacingOccurrences(of: "\n", with: ""))"
                
                
                let attrs = [NSAttributedStringKey.font : cell.address.font, NSAttributedStringKey.foregroundColor : UIColor.lightGray] as [NSAttributedStringKey : Any]
                let boldString = NSMutableAttributedString(string: boldText, attributes:attrs)
                attributedString.append(boldString)
                cell.projectname.attributedText = attributedString
                //cell.projectname.attributedText = "\(project.title)\n\(project.address.replacingOccurrences(of: "\n", with: ""))"
                if(tempLocation!.distance(from: currentLocation!) * 0.000621371192 < 1000){
                    cell.distance.text = "\(Double(round(tempLocation!.distance(from: currentLocation!) * 0.000621371192 * 100) / 100)) mi."
                }else{
                    cell.distance.text = "1000+ mi."
                }
                cell.accessoryType = .disclosureIndicator
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
                        self.navigationController?.navigationBar.barTintColor = UIColor.white
                        self.navigationItem.rightBarButtonItems = nil
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
                        self.makeNavigationBarButtons()
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
        self.tableView.isHidden = false
        if(locationManager.location != nil){
            self.currentLocation = locationManager.location
        }else{
            self.currentLocation = CLLocation.init(latitude: 38.904449, longitude: -77.046797)
        }
     self.navigationItem.rightBarButtonItems = nil
        if(self.searchController.searchBar.text?.count == 0){
            self.arrFilter = [String]()
            self.arrCountry = [String]()
            self.tableView.reloadData()
        }
        self.searchBar.resignFirstResponder()
        self.searchBar.showsCancelButton = false
        selected_searchbar = "searchcontroller"
        slideUpView.isHidden = true
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        mapViewTopConstraint.constant = 0
        self.tableView.isHidden = true
        DispatchQueue.main.async {
            self.makeNavigationBarButtons()
        }
        
        //slideUpView.isHidden = false
        self.arrProjects = [String]()
        arrFilter = [String]()
        self.navigationItem.rightBarButtonItems = nil
        self.allDownloaded = false
        self.from = 0
        self.projects = [Project]()
        self.loadProjectsElasticUsingLocation(search: searchController.searchBar.text!, category: "All", lat: self.queryingLat, lng: self.queryingLng, distance: queryingDistance)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListHeader")
        (cell as? ListHeader)?.projects.text = "Projects"
        if(self.searchedProjects.count <= 1){
            (cell as? ListHeader)?.rightside.text = "\(self.searchedProjects.count) Result"
        }else{
            (cell as? ListHeader)?.rightside.text = "\(self.searchedProjects.count) Results"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.keyboardDismissMode = .onDrag
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
            controller.searchBar.showsScopeBar = true
            controller.hidesNavigationBarDuringPresentation = false;
            controller.searchBar.searchBarStyle = .minimal;
            controller.searchBar.barTintColor = UIColor.white
            controller.searchBar.barTintColor = UIColor.white
            controller.searchBar.searchBarStyle = .default
            controller.searchBar.isTranslucent = true
            return controller
        })()
        
        
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
        makeNavigationBarButtons()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
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
        
        let filterButton = UIButton(frame: CGRect(x: 0, y: 0, width: 28, height: 24))
        filterButton.setImage(UIImage(named: "Filter_BU"), for: .normal)
        filterButton.imageView?.contentMode = .scaleAspectFit
        filterButton.addTarget(self, action: #selector(self.handleFilter(_:)), for: .touchUpInside)
        let filterBarButton = UIBarButtonItem(customView: filterButton)
        
        let listButton = UIButton(frame: CGRect(x: 0, y: 0, width: 28, height: 24))
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
        projectsListTab.category = category
        projectsListTab.totalCount = totalCount
        projectsListTab.selectedfilter = selectedfilter
        projectsListTab.certificationsarray = self.certificationsarray
        projectsListTab.ratingsarray = self.ratingsarray
        projectsListTab.versionsarray = self.versionsarray
        projectsListTab.countriesarray = self.countriesarray
        projectsListTab.statesarray = self.statesarray
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
            if let viewController = segue.destination as? ProjectDetailsViewController {
                viewController.node_id = searchedProjects[sender as! Int].node_id
                viewController.projectID = searchedProjects[sender as! Int].ID
                viewController.navigationItem.title = searchedProjects[sender as! Int].title
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
            mapView.animate(to: camera)
        }
        locationManager.delegate = nil
        //self.loadProjectsElastic(search: self.searchText, category: self.category)
        self.loadMapView()
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
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
    
    func loadMapView(){
        var i = 0
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
            clusterManager?.cluster()
            //mapView.animate(with: GMSCameraUpdate.fit(bounds!, withPadding: 30.0))
        }else{
            if(self.navigationController != nil){
                Utility.showToast(y: self.navigationController!.navigationBar.frame.size.height, message: "Map not loaded, try again later!")
            }
        }
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
                                                 zoom: mapView.camera.zoom + 1)
        let update = GMSCameraUpdate.setCamera(newCamera)
        mapView.moveCamera(update)
        return false
    }
}


extension ViewController : GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if marker.userData is ClusterItem{
            markerTapped = true
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
            if marker.userData is ClusterItem{
                if(self.projects.count > 0){
                    marker.icon = UIImage(named: "pin")
                    marker.title = self.projects[(marker.userData as! ClusterItem).index].title
                    marker.snippet = self.projects[(marker.userData as! ClusterItem).index].address.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
        distanceMetres = distanceMetres/1000
        print("Entered region", distanceMetres)
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {        
      //loadData()
        DispatchQueue.main.async {
        var  bottomLeftCoord = mapView.projection.visibleRegion().nearLeft;
        var bottomRightCoord = mapView.projection.visibleRegion().nearRight;
        var distanceinKms = GMSGeometryDistance(bottomLeftCoord, bottomRightCoord)
        distanceinKms = distanceinKms/1000
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
                    self.loadMapView()
                }
                
                break
            }
        }
    }
    
    func loadData(){
        var  bottomLeftCoord = mapView.projection.visibleRegion().nearLeft;
        var bottomRightCoord = mapView.projection.visibleRegion().nearRight;
        var distanceMetres = GMSGeometryDistance(bottomLeftCoord, bottomRightCoord)
        distanceMetres = distanceMetres/1000
        let point = mapView.center;
        var  coordinate = self.mapView.projection.coordinate(for: point)
        if(locationManager.location != nil){
            let region = CLCircularRegion.init(center: coordinate, radius: distanceMetres * 1000, identifier: "myRegion")
            if(region.contains((locationManager.location?.coordinate)!)){
                coordinate = (locationManager.location?.coordinate)!
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            Apimanager.shared.stopAllSessions()
            self.queryingLat = coordinate.latitude
            self.queryingLng = coordinate.longitude
            self.queryingDistance = distanceMetres
            self.allDownloaded = false
            self.from = 0
            self.size = 500
            self.mapView.clear()
            self.projects = [Project]()
            if(self.searchController.isActive){
                self.loadProjectsElasticUsingLocation(search: self.searchController.searchBar.text!, category: self.category, lat: coordinate.latitude , lng: coordinate.longitude, distance: distanceMetres)
            }else if(self.searchBar.text!.count > 0){
                
            }else{
                self.loadProjectsElasticUsingLocation(search: "", category: self.category, lat: coordinate.latitude , lng: coordinate.longitude, distance: distanceMetres)
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
        self.searchController.dismiss(animated: true, completion: nil)
        searchBar.tintColor = UIColor.black
        let attributes = [NSAttributedStringKey.foregroundColor : self.searchController.searchBar.tintColor]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
        searchBar.showsCancelButton = true
        selected_searchbar = "searchbar"
        self.arrCountry.removeAll()
        self.arrFilter.removeAll()
        self.arrCountry.append("Current location")
        self.tableView.reloadData()
        slideUpView.isHidden = true
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        slideUpView.isHidden = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        request = MKLocalSearchRequest()
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchText = ""
        locationsearchTxt = ""
        searchBar.resignFirstResponder()
        if(selected_searchbar == "searchbar"){
            self.tableView.isHidden = true
        }
        slideUpView.isHidden = false
        hideSearch()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchTxt: String) {
        
        request.naturalLanguageQuery = searchTxt
        
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.arrCountry.removeAll()
            self.arrCountry.append("Current location")
            for i in response.mapItems{
                print(i.placemark.name)
                self.arrCountry.append(i.placemark.name!)
                print(i.placemark.coordinate.latitude)
                print(i.placemark.coordinate.longitude)
            }
            if(self.mapViewTopConstraint.constant != 0){
                self.tableView.isHidden = false
                self.tableView.reloadData()
            }
        }
        
    }
    
}