//
//  ProjectListViewController.swift
//  USGBC
//
//  Created by Pradheep Narendran on 20/08/17.
//  Copyright © 2017 U.S Green Building Council. All rights reserved.
//

import UIKit
import SwiftyJSON
import MapKit
import SDWebImage
import Alamofire

class ProjectListViewController: UIViewController, UIPopoverControllerDelegate, UIPopoverPresentationControllerDelegate, UISearchResultsUpdating, UISearchControllerDelegate, CLLocationManagerDelegate {
    var selected_searchbar = ""
    var zoomLevel = 0.0
    var currentPosition = GMSCameraPosition()
    var allDownloaded = false
    var queryingDistance = 0.0
    var totalRecords = 0
    var  request = MKLocalSearchRequest()
    var currentLocation = CLLocation()
    var locationsearchTxt = ""
    var selected_tags = [String]()
    var tagarray = NSMutableArray()
    let locationManager = CLLocationManager()
    var tags = NSMutableArray()
    var arrCountry = ["Afghanistan", "Algeria", "Bahrain","Brazil", "Cuba", "Denmark","Denmark", "Georgia", "Hong Kong", "Iceland", "India", "Japan", "Kuwait", "Nepal"];
    var arrFilter:[String] = []
    var countriesdict = NSMutableDictionary()
    var statesdict = NSMutableDictionary()
    var statesarray = NSMutableArray()
    var countriesarray = NSMutableArray()
    var states = NSMutableArray()
    var countries = NSMutableArray()
    var arrProjects = [String]()
    var selectedfilter : [String] = ["all","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    fileprivate var searchText = ""
    var category = ""
    var timer = Timer()
    fileprivate var loadType = "init"
    fileprivate var pageNumber = 0
    fileprivate var pageSize = 50
    fileprivate var lastRecordsCount = 0
    fileprivate var loading = false
    fileprivate var searchOpen = false
    var projects: [Project] = []
    var searchedProjects: [Project] = []
    var filterProjects: [Project] = []
    var totalCount = 0
    var ratingsarray = NSMutableArray()
    var versionsarray = NSMutableArray()
    var certificationsarray = NSMutableArray()
    var from = 0
    var size = 500
    var filterChanged = false        
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nodata: UILabel!
    
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    var searchController = UISearchController()
    var searchController1 = UISearchController()
    
    @IBOutlet weak var locationtableView: UITableView!

    
    func updateSearchResults(for searchController: UISearchController) {
        // To show another search view controller mapViewTopConstraint.constant = 54
        //mapView.isHidden = true

        
        //self.tableView.reloadData()
    }
    
    
    @objc func searchProjects(){
        

        
        
        DispatchQueue.main.async {
            print(self.category)
            self.searchProjectUsingLocation(search: self.searchController.searchBar.text!, category: self.category, lat: self.currentPosition.target.latitude , lng: self.currentPosition.target.longitude, distance: self.queryingDistance)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Bounce back to the main thread to update the UI
        Apimanager.shared.stopAllSessions()
        DispatchQueue.main.async {
            Utility.hideLoading()
            AWBanner.hide()
        }
        
        
    }
    

    func didPresentSearchController(_ searchController: UISearchController) {
        self.tableView.isHidden = false
        
        if(self.searchController.searchBar.text?.count == 0){
            self.arrFilter = [String]()
            self.arrCountry = [String]()
            self.tableView.reloadData()
        }
        self.searchBar.resignFirstResponder()
        self.searchBar.showsCancelButton = false
        selected_searchbar = "searchcontroller"
        
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        
        DispatchQueue.main.async {
            self.makeNavigationBarButtons()
        }
        
        //slideUpView.isHidden = false
        self.arrProjects = [String]()
        arrFilter = [String]()
        
        self.allDownloaded = false
        self.from = 0
        self.projects = [Project]()
        self.loadProjectsElasticUsingLocation(search: self.searchController.searchBar.text!, category: self.category, lat: self.currentPosition.target.latitude , lng: self.currentPosition.target.longitude, distance: self.queryingDistance)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations.first!
        locationManager.delegate = nil        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView.init(frame: .zero)
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        self.tableView.contentInset = UIEdgeInsetsMake(0,0,0,0);
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.locationtableView.isHidden = true
        tableView.register(UINib(nibName: "ProjectCellwithImage", bundle: nil), forCellReuseIdentifier: "ProjectCellwithImage")
        tableView.register(UINib(nibName: "ProjectCellwithoutImage", bundle: nil), forCellReuseIdentifier: "ProjectCellwithoutImage")
        tableView.register(UINib(nibName: "ListHeader", bundle: nil), forCellReuseIdentifier: "ListHeader")
        locationtableView.register(UINib.init(nibName:"locationcell", bundle: nil), forCellReuseIdentifier: "locationcell")
        self.searchBar.delegate = self
        nodata.text = "No data found"
        self.searchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchBar.searchBarStyle = .minimal
            controller.dimsBackgroundDuringPresentation = false
            controller.searchResultsUpdater = self
            controller.searchBar.showsCancelButton = false
            controller.searchBar.delegate = self
            controller.searchBar.sizeToFit()
            if(UserDefaults.standard.object(forKey: "searchText") != nil){
                controller.searchBar.text = UserDefaults.standard.object(forKey: "searchText") as! String
            }
            controller.searchBar.showsScopeBar = true
            (controller.searchBar.value(forKey: "searchField") as? UITextField)?.font = UIFont.AktivGrotesk_Md(size: 14)
            controller.hidesNavigationBarDuringPresentation = false;
            controller.searchBar.searchBarStyle = .minimal;
            controller.searchBar.barTintColor = UIColor.white
            controller.searchBar.barTintColor = UIColor.white
            controller.searchBar.searchBarStyle = .default
            controller.searchBar.isTranslucent = true
            return controller
        })()
        
        searchBar.textField.clearButtonMode = .never
        self.searchController.searchBar.textField.clearButtonMode = .never
        
        self.searchController.delegate = self
        
        
        
        self.searchController1 = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchBar.searchBarStyle = .minimal
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.placeholder = "Search Location"
            controller.searchResultsUpdater = self
            controller.searchBar.sizeToFit()
            controller.searchBar.showsScopeBar = true
            controller.hidesNavigationBarDuringPresentation = false;
            controller.searchBar.searchBarStyle = .minimal;
            controller.searchBar.barTintColor = UIColor.white
            return controller
        })()
        
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        // Include the search bar within the navigation bar.
        self.navigationItem.titleView = self.searchController.searchBar;
        //self.tableView.tableHeaderView = self.searchController1.searchBar;
        
        
        self.definesPresentationContext = true;
        //Colors.primaryColor = "#00B782"
        loadType = "init"
        pageNumber = 0
        //loadProjects(category: category, search: searchText, page: pageNumber, loadType: loadType)
        from = 0
        //self.searchText = self.searchBar.text!
        DispatchQueue.main.async {
            if(UserDefaults.standard.object(forKey: "ProjectOffline") != nil){
                var unkeyed = NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "ProjectOffline") as! Data)
                //self.projects = unkeyed as! [Project]
                //self.filterProjects = self.projects
                self.tableView.reloadData()
                if(self.projects.count == 0){
                    //Utility.showLoading()
                }
            }else{
                //Utility.showLoading()
            }
            self.tableView.keyboardDismissMode = .onDrag
            self.initViews()
            self.nodata.isHidden = true
            self.loading = true
           if(self.filterProjects.count == 0){
            }
            
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
            if(tempcerts.count > 0 || tempratings.count > 0 || tempversions.count > 0 || tempstate.count > 0 || tempcountry.count > 0 || (self.searchController.searchBar.text?.count)! > 0){
                self.searchProjects()
            }else{
                Utility.showLoading()
                self.loadProjectsElasticUsingLocation(search: self.searchController.searchBar.text!, category: self.category, lat: self.currentPosition.target.latitude , lng: self.currentPosition.target.longitude, distance: self.queryingDistance)
            }
            
            
        }
        
    }
    
    
    func loadProjectsElasticUsingLocation(search: String, category: String, lat : Double, lng : Double, distance : Double){
        //sizee was 500000
        
        if(!allDownloaded){
            var dict = [[String : Any]]()
            dict = self.constructCategory()
            self.navigationItem.rightBarButtonItems = nil
            self.makeNavigationBarButtons()
            Apimanager.shared.getProjectsElasticForMapNew (from: self.from, sizee : size, search : search, category : dict, lat : lat, lng : lng, distance : distance, callback: {(totalRecords, projects, code) in
                if(code == -1 && projects != nil){
                    self.totalRecords = totalRecords!
                    self.totalCount = totalRecords!
                    self.from = self.from + self.size
                    for i in projects!{
                        self.projects.append(i)
                    }
                    
                    self.searchedProjects = self.projects
                    //self.lastRecordsCount = projects!.count
                    self.filterProjects = self.projects
                    DispatchQueue.main.async {
                        Utility.hideLoading()
                        self.arrProjects = [String]()
                        self.arrFilter = [String]()
                        self.arrCountry = [String]()
                        if(CLLocationManager.locationServicesEnabled()){
                            if(projects!.count > 0  && self.filterProjects.count < 5001){
                                self.loading = false
                                self.tableView.reloadData()
                            }else{
                                self.loading = false
                                self.allDownloaded = true
                                self.tableView.reloadData()
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
    
    
    func searchProjectUsingLocation(search: String, category: String, lat : Double, lng : Double, distance : Double){
        //sizee was 500000f
        var dict = [[String : Any]]()
        self.navigationItem.rightBarButtonItems = nil
        self.makeNavigationBarButtons()
        dict = self.constructCategory()
        Apimanager.shared.searchProjectsElasticForMapNew (from: self.from, sizee : 1000, search : search, category : dict, callback: {(totalRecords, projects, code) in
            if(code == -1 && projects != nil){
                DispatchQueue.main.async {
                    Utility.hideLoading()
                    self.arrProjects = [String]()
                    self.arrFilter = [String]()
                    for i in projects!{
                        self.searchedProjects.append(i)
                    }
                    self.filterProjects = self.searchedProjects
                    self.loading = false
                    self.totalCount = totalRecords!
                    self.from = self.from + projects!.count
                    self.tableView.reloadData()
                    if(projects!.count == 0){
                        self.loading = true
                    }
                        //self.lastRecordsCount = projects!.count
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
        listButton.setImage(UIImage(named: "map_black"), for: .normal)
        listButton.imageView?.contentMode = .scaleAspectFit
        listButton.addTarget(self, action:#selector(self.handleMap(_:)), for: .touchUpInside)
        let listBarButton = UIBarButtonItem(customView: listButton)
        
        
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white] as [AnyHashable : NSObject]
        //[NSAttributedStringKey.foregroundColor:UIColor.white, kCTFontAttributeName : UIFont.gothamBook(size: 18) ] as [AnyHashable : NSObject]
        navigationController?.navigationBar.titleTextAttributes = textAttributes as! [NSAttributedStringKey : Any]
        self.navigationItem.title = "Projects"
        self.navigationItem.rightBarButtonItems = [listBarButton, filterBarButton]
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
    }
    
    @objc func loadmore(){
        DispatchQueue.main.async {
            //Utility.showLoading()
            //self.loadProjectsWithPagination(from: self.from, size: self.size, category: self.category, search: self.searchText, loadType: self.loadType)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        tabBarController?.title = "Projects"
        loadType = "init"
        pageNumber = 0
        //loadProjects(category: category, search: searchText, page: pageNumber, loadType: loadType)
        from = 0
//        self.searchText = self.searchBar.text!
//        searchBar.tintColor = UIColor.white
//        searchBar.barTintColor = UIColor.hex(hex: Colors.primaryColor)
//        searchBar.layer.borderWidth = 1
//        searchBar.layer.borderColor = UIColor.hex(hex: Colors.primaryColor).cgColor
        //right nav buttons
        makeNavigationBarButtons()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        //self.loading = true
    }

    
    func initViews(){
        tableView.delegate = self
        tableView.dataSource = self
        //searchBar.delegate = self
        
        
        
        //Refresh control for UICollectionView
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.hex(hex: Colors.primaryColor)
        //refreshControl.addTarget(self, action: #selector(ProjectListViewController.handleRefresh(_:)), for: .valueChanged)
        //tableView.addSubview(refreshControl)
        tableView.alwaysBounceVertical = true
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(tableView != locationtableView){
            let cell = tableView.dequeueReusableCell(withIdentifier: "ListHeader")
            (cell as? ListHeader)?.projects.text = "Projects (\(self.totalCount))"
            (cell as? ListHeader)?.rightside.text = ""
            return cell
        }
        return tableView.headerView(forSection: section)
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(tableView != locationtableView){
            return 40;
        }
        return 1
    }
    
    //MARK: - IBActions
    @IBAction func handleRefresh(_ sender: UIRefreshControl){
        sender.endRefreshing()
        //category = "All"
        searchText = ""
        pageNumber = 0
        loadType = "init"
        if(searchOpen){
//            searchBar.text = ""
//            searchText = ""
//            searchBar.showsCancelButton = false
//            searchBar.resignFirstResponder()
            hideSearch()
        }
        //loadProjects(category: category, search: searchText, page: pageNumber, loadType: loadType)
        //loadProjectsWithPagination(filterChanged: filterChanged, id: "", category: category, loadType: loadType)
        from = 0
        size = 500
        DispatchQueue.main.async{
            self.loadType = "init"
            self.pageNumber = 0
            Apimanager.shared.stopAllSessions()
            //Utility.showLoading()
            self.loading = true
            self.projects = [Project]()
            self.filterProjects = [Project]()
            self.searchedProjects = [Project]()
            self.loadProjectsElasticUsingLocation(search: self.searchController.searchBar.text!, category: self.category, lat: self.currentPosition.target.latitude , lng: self.currentPosition.target.longitude, distance: self.queryingDistance)
        }
        
    }
    
    @objc func handleFilter(_ sender: Any){
        performSegue(withIdentifier: "Filterproject", sender: self)
    }
    
    @objc func handleSearch(_ sender: Any){
//        if(!searchOpen){
//            searchBar.becomeFirstResponder()
//            showSearch()
//        }else{
//            searchBar.resignFirstResponder()
//            hideSearch()
//        }
    }
    
    func showSearch(){
        //collectionViewTopConstraint.constant = 54
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
        //collectionViewTopConstraint.constant = 0
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
    
    @objc func handleMap(_ sender: Any){
        let transition = CATransition()
        transition.duration = 0.4
        transition.type = "flip"
        transition.subtype = kCATransitionFromRight
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        let sb = UIStoryboard(name: "Main", bundle: nil)
        Apimanager.shared.stopAllSessions()
        //        self.navigationController?.pushViewController(projectsMapTab, animated: false)
        
        let projectsMapTab = sb.instantiateViewController(withIdentifier: "mapViewController") as! ViewController
        let projectsTabBarItem = UITabBarItem(title: "Projects", image: UIImage(named: "projects_empty"), selectedImage: UIImage(named: "projects_filled"))        
        projectsMapTab.category = category
        projectsMapTab.totalCount = totalCount
        projectsMapTab.selectedfilter = selectedfilter
        projectsMapTab.certificationsarray = self.certificationsarray
        projectsMapTab.ratingsarray = self.ratingsarray
        projectsMapTab.versionsarray = self.versionsarray
        projectsMapTab.countriesarray = self.countriesarray
        projectsMapTab.statesarray = self.statesarray
        projectsMapTab.zoomLevel = Float(self.zoomLevel)
        projectsMapTab.currentPosition = self.currentPosition
        UserDefaults.standard.set(self.searchController.searchBar.text!, forKey: "searchText")
        navigationController?.viewControllers[0] = projectsMapTab
    }
    var opened = false
    //To load JSON from file
    func loadProjects(category: String, search: String, page: Int, loadType: String){
        //Utility.showLoading()
        Apimanager.shared.getProjectsNew (category: category, search: search, page: page, callback: {(projects, code) in
            if(code == -1 && projects != nil){
                Utility.hideLoading()
                self.filterChanged = false
                if(loadType == "init"){
                    var tempp = projects!
                    if(self.selected_tags.count > 0){
                        tempp.removeAll()
                        for i in projects!{
                            var s = i as! Project
                            if(self.selected_tags.contains(s.ID)){
                                tempp.append(s)
                            }
                        }
                    }else{
                        tempp = projects!
                    }
                    self.projects = tempp
                    self.lastRecordsCount = tempp.count
                    self.filterProjects = self.projects
                    var keyed = NSKeyedArchiver.archivedData(withRootObject: self.projects)
                    UserDefaults.standard.set(keyed, forKey: "OrganizationOffline")
                    self.tableView.setContentOffset(.zero, animated: false)
                    self.tableView.reloadData()
                    print("init")
                    if(self.filterProjects.count == 0){
                        self.nodata.isHidden = false
                    }else{
                        self.nodata.isHidden = true
                    }
                    DispatchQueue.main.async {
                        if(tempp.count < 15 /* New count */){
                            self.loading = true
                            Utility.hideLoading()
                            if(tempp.count > 0){
                                if(self.navigationController != nil){
                                    print("vcx ", self.from,self.pageNumber,self.projects.count)
                                    Utility.showToast(y: self.navigationController!.navigationBar.frame.size.height, message: "That was all")
                                }
                            }
                        }else{
                            Utility.hideLoading()
                            self.loading = false
                        }
                    }
                    print(self.filterProjects.count)
                }else{
                    self.projects.append(contentsOf: projects!)
                    self.lastRecordsCount = projects!.count
                    self.filterProjects = self.projects
                    self.tableView.reloadData()
                    self.loading = false
                    print("more")
                    if(self.filterProjects.count == 0){
                        self.nodata.isHidden = false
                    }else{
                        self.nodata.isHidden = true
                    }
                    print(self.filterProjects.count)
                }
            }else{
                if(code == 401){
                    if(self.opened == false){
                        self.opened = true
                        Utility.hideLoading()
                        Utility.revokeduser(viewcontroller: self, name: "")
                    }
                }else if(code != -999 && code != nil && code != 0){
                    Utility.hideLoading()
                    if(self.navigationController != nil){
                        Utility.showToast(y: self.navigationController!.navigationBar.frame.size.height, message: "Something went wrong")
                    }
                }
            }
        })
    }
    
    //@IBOutlet weak var nodata: UILabel!
    func loadProjectsWithPagination(from: Int , size: Int, category: String, search: String,  loadType: String){
        print(category)
        Apimanager.shared.getProjectsElasticWithpaginationNew(from: from, sizee: size, search: search, category:  category, callback: { totalCount, projects, code in
            if(code == -1 && projects != nil){
                self.totalCount = totalCount!
                if(loadType == "init"){
                    self.totalCount = totalCount!
                    var tempp = projects!
                    if(self.selected_tags.count > 0){
                        tempp.removeAll()
                        for i in projects!{
                            var s = i as! Project
                            if(self.selected_tags.contains(s.ID)){
                                tempp.append(s)
                            }
                        }
                    }else{
                        tempp = projects!
                    }
                    self.projects = tempp
                    self.lastRecordsCount = tempp.count
                    self.filterProjects = self.projects
                    var keyed = NSKeyedArchiver.archivedData(withRootObject: self.projects)
                    //UserDefaults.standard.set(keyed, forKey: "ProjectOffline")
                    self.tableView.setContentOffset(.zero, animated: false)
                    self.tableView.reloadData()
                    print("init")
                    print(self.filterProjects.count)
                    self.from += projects!.count
                    self.loading = false
                    self.pageNumber += projects!.count
                    DispatchQueue.main.async {
                        if(self.filterProjects.count > 0){
                            self.nodata.isHidden = true
                        }else{
                            self.nodata.isHidden = false
                        }
                        Utility.hideLoading()
                    }
                    
                }else{
                    if(projects!.count > 0){
                        self.projects.append(contentsOf: projects!)
                        self.lastRecordsCount = projects!.count
                        self.filterProjects = self.projects
                        self.tableView.reloadData()
                        self.loading = false
                        self.pageNumber += projects!.count
                        print("more")
                        print(self.filterProjects.count)
                        self.from += projects!.count
                        DispatchQueue.main.async {
                            if(self.filterProjects.count > 0){
                                self.nodata.isHidden = true
                            }else{
                                self.nodata.isHidden = false
                            }
                            Utility.hideLoading()
                        }
                    }else{
                        self.loading = true
                        DispatchQueue.main.async {
                            Utility.hideLoading()
                            if(self.filterProjects.count > 0){
                                self.nodata.isHidden = true
                            }else{
                                self.nodata.isHidden = false
                            }
                            if(self.navigationController != nil){
                                print("vcx ", self.from,self.pageNumber,self.projects.count)
                                Utility.showToast(y: self.navigationController!.navigationBar.frame.size.height, message: "That was all")
                            }
                        }
                    }
                }
            }else{
                if(code == 401){
                    if(self.opened == false){
                        self.opened = true
                        Utility.hideLoading()
                        Utility.revokeduser(viewcontroller: self, name: "")
                    }
                }else if(code != -999 && code != nil && code != 0){
                    Utility.hideLoading()
                    if(self.navigationController != nil){
                        Utility.showToast(y: self.navigationController!.navigationBar.frame.size.height, message: "Something went wrong")
                    }
                }
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        UIApplication.shared.setStatusBarHidden(false, with: .none)
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = self.tabBarController?.tabBar.tintColor
        AppUtility.lockOrientation(.all)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProjectDetailsViewController" {
            if let vc = segue.destination as? ProjectDetailsViewController {
                if(self.searchController.isActive){
                    vc.node_id = filterProjects[sender as! Int].node_id
                    vc.projectID = filterProjects[sender as! Int].ID
                    vc.currentProject = filterProjects[sender as! Int]
                    vc.currentLocation = self.currentLocation
                    vc.navigationItem.title = vc.currentProject.title
                }else{
                    vc.currentProject = filterProjects[sender as! Int]
                    vc.node_id = filterProjects[sender as! Int].node_id
                    vc.projectID = filterProjects[sender as! Int].ID
                    vc.currentProject = filterProjects[sender as! Int]
                    vc.currentLocation = self.currentLocation
                    vc.navigationItem.title = vc.currentProject.title
                }
                //viewController.navigationItem.title = searchedProjects[sender as! Int].title
            }
        }else if segue.identifier == "Filterproject" {
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
        }
    }
    
}

//MARK: UICollectionView delegates
extension ProjectListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView != locationtableView){
            return filterProjects.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView != locationtableView){
            let project = filterProjects[indexPath.row]
            if(project.image.count > 0 && project.image.range(of: "placeholder") == nil){
                    //return 85
                return UITableViewAutomaticDimension
            }else{
                return UITableViewAutomaticDimension
            }
        }
        if(indexPath.row == 0){
            return 50
        }
        return 44
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView != locationtableView){
        let project = filterProjects[indexPath.row]
        var tempLocation = currentLocation
        if(project.lat != "" && project.long != ""){
           tempLocation = CLLocation.init(latitude: Double(project.lat)!, longitude: Double(project.long)!)
        }
        if(project.image.count > 0 && project.image.range(of: "placeholder") == nil){
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCellwithImage", for: indexPath) as! ProjectCellwithImage
            cell.accessoryType = .disclosureIndicator
            //cell.projectname.text = "\(project.title)"
            project.title = project.title.replacingOccurrences(of: "&amp;", with: "")
            let normalText  = "\(project.title)"
            let attributedString = NSMutableAttributedString(string:normalText)
            var distance = ""
            var location = CLLocation()
            if(locationManager.location != nil){
                location = locationManager.location!
            }else{
                location = CLLocation.init(latitude: currentPosition.target.latitude, longitude: currentPosition.target.longitude)
            }
            if(tempLocation.distance(from: location)/1609.34 < 1000){
                distance = "\(Double(round(tempLocation.distance(from: location)/1609.34 * 100)/100)) mi. away"
            }else{
                distance = "1000+ mi. away"
            }
            var t = ""
            if(project.city.count > 0){
                t = t + project.city + ", "
            }
            
            if(project.state.count > 0){
                t = t + project.state + ", "
            }
            
            if(project.country.count > 0){
                t = t + project.country
            }
            
            if(t[t.index(before: t.endIndex)] != ","){
                t = String(t.prefix(t.count - 1))
            }
            
            var boldText = "\n\(t)\n\(distance)"
            var mutableParagraphStyle = NSMutableParagraphStyle()
            
            // *** set LineSpacing property in points ***
            mutableParagraphStyle.lineSpacing = 4 // Whatever line spacing you want in points
            //bold.addAttribute(NSAttributedStringKey.paragraphStyle , value: mutableParagraphStyle, range: NSMakeRange(0, boldText.count))
            
            
            let attrs = [NSAttributedStringKey.font : cell.address.font] as [NSAttributedStringKey : Any]
            var boldString = NSMutableAttributedString(string: boldText, attributes:attrs)
            boldString.addAttribute(NSAttributedStringKey.paragraphStyle , value: mutableParagraphStyle, range: NSMakeRange(0, boldText.count))
            
            
            boldString.addAttribute(NSAttributedStringKey.foregroundColor , value: UIColor(red:0.53, green:0.60, blue:0.64, alpha:1.0), range: NSMakeRange("\n\(t)".count, distance.count + 1 ))
            
            attributedString.append(boldString)
            cell.projectname.attributedText = attributedString
            //cell.address.text = "\(project.address.replacingOccurrences(of: "\n", with: ""))"
            cell.project_image.center.y = cell.contentView.frame.size.height/2
            cell.project_image.image = nil
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
            cell.accessoryType = .disclosureIndicator
            //cell.address.text = "\(project.address.replacingOccurrences(of: "\n", with: ""))"
            project.title = project.title.replacingOccurrences(of: "&amp;", with: "")
            let normalText  = "\(project.title)"
            
            let attributedString = NSMutableAttributedString(string:normalText)
            
            var distance = ""
            var location = CLLocation()
            if(locationManager.location != nil){
                location = locationManager.location!
            }else{
                location = CLLocation.init(latitude: currentPosition.target.latitude, longitude: currentPosition.target.longitude)
            }
            if(tempLocation.distance(from: location)/1609.34 < 1000){
                distance = "\(Double(round(tempLocation.distance(from: location)/1609.34 * 100)/100)) mi. away"
            }else{
                distance = "1000+ mi. away"
            }
            var t = ""
            if(project.city.count > 0){
                t = t + project.city + ", "
            }
            
            if(project.state.count > 0){
                t = t + project.state + ", "
            }
            
            if(project.country.count > 0){
                t = t + project.country
            }
            
            if(t[t.index(before: t.endIndex)] == ","){
                t = String(t.prefix(t.count - 1))
            }
            
            var boldText = "\n\(t)\n\(distance)"
            //var boldText = "\n\(project.city), \(project.country)\n\(distance)"
            var mutableParagraphStyle = NSMutableParagraphStyle()
            
            // *** set LineSpacing property in points ***
            mutableParagraphStyle.lineSpacing = 4 // Whatever line spacing you want in points
            //bold.addAttribute(NSAttributedStringKey.paragraphStyle , value: mutableParagraphStyle, range: NSMakeRange(0, boldText.count))
            
            
            let attrs = [NSAttributedStringKey.font : cell.address.font] as [NSAttributedStringKey : Any]
            var boldString = NSMutableAttributedString(string: boldText, attributes:attrs)
            boldString.addAttribute(NSAttributedStringKey.paragraphStyle , value: mutableParagraphStyle, range: NSMakeRange(0, boldText.count))
            
            
            boldString.addAttribute(NSAttributedStringKey.foregroundColor , value: UIColor(red:0.53, green:0.60, blue:0.64, alpha:1.0), range: NSMakeRange("\n\(t)".count, distance.count + 1))
            
            attributedString.append(boldString)
            cell.projectname.attributedText = attributedString
            //cell.projectname.attributedText = "\(project.title)\n\(project.address.replacingOccurrences(of: "\n", with: ""))"
            
            return cell
        }
        }
        if(!self.searchController.isActive && indexPath.row == 0){
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "locationcell", for: indexPath) as! locationcell
            return cell1
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            configureCell(cell: cell, forRowAtIndexPath: indexPath)
            return cell
        }
    }
    
    func configureCell(cell: UITableViewCell, forRowAtIndexPath: IndexPath) {
        // 3
        if (self.searchController.isActive) {
            cell.textLabel?.text = arrFilter[forRowAtIndexPath.row]
        } else {
            cell.textLabel?.text = arrCountry[forRowAtIndexPath.row]
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print(indexPath.row)
        print(filterProjects.count/2 )
        if indexPath.row > filterProjects.count/2 && !loading && self.filterProjects.count < self.totalCount{
                DispatchQueue.main.async {
                    //Utility.showLoading()
                    self.loadType = "more"
                    //loadProjects(category: category, search: searchText, page: pageNumber, loadType: loadType)
                    self.loading = true
                    self.allDownloaded = false
                    //Apimanager.shared.stopAllSessions()
                    //Utility.showLoading()
                //self.loadProjectsElasticUsingLocation(search: self.searchController.searchBar.text!, category: self.category, lat: self.currentPosition.target.latitude , lng: self.currentPosition.target.longitude , distance: self.queryingDistance)
                    
                    let tempcerts = self.certificationsarray
                    let tempratings = self.ratingsarray
                    let tempversions = self.versionsarray
                    let tempstate = self.statesarray
                    let tempcountry = self.countriesarray
                    tempcerts.remove("")
                    tempratings.remove("")
                    tempversions.remove("")
                    tempstate.remove("")
                    tempcountry.remove("")
                    if(tempcerts.count > 0 || tempratings.count > 0 || tempversions.count > 0 || tempstate.count > 0 || tempcountry.count > 0 || (self.searchController.searchBar.text?.count)! > 0){
                        self.searchProjects()
                    }else{
                        self.loadProjectsElasticUsingLocation(search: self.searchController.searchBar.text!, category: self.category, lat: self.currentPosition.target.latitude , lng: self.currentPosition.target.longitude, distance: self.queryingDistance)
                    }
                    
                    
                }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(tableView != locationtableView){
            self.tableView.deselectRow(at: indexPath, animated: true)
            if UI_USER_INTERFACE_IDIOM() == .phone {
                AppUtility.lockOrientation(.portrait)
                let value = UIInterfaceOrientation.portrait.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
            }
            performSegue(withIdentifier: "ProjectDetailsViewController", sender: indexPath.row)
        }else{
            if (self.searchController.isActive) {
                self.searchController.searchBar.resignFirstResponder()
            }else{
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
            self.locationtableView.isHidden = true
        }
    }
}

//MARK: - UISearchBar Delegate
extension ProjectListViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        searchBar.tintColor = UIColor.black
//        let attributes = [NSAttributedStringKey.foregroundColor : self.searchController.searchBar.tintColor]
//        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
//        searchBar.showsCancelButton = true
//        makeNavigationBarButtons()
//        selected_searchbar = "searchbar"
//        self.arrCountry.removeAll()
//        self.arrCountry.append("Current location")
//        self.locationtableView.reloadData()
//        self.searchController.dismiss(animated: true, completion: nil)
        for subview in searchBar.subviews {
            for innerSubview in subview.subviews {
                if innerSubview is UITextField {
                    innerSubview.backgroundColor = UIColor(red:0.945, green:0.945, blue:0.945, alpha:1.0)
                    break
                }
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
//        searchBar.showsCancelButton = false
//        searchBar.text = ""
//        searchText = ""
//        searchBar.resignFirstResponder()
//        tableViewTopConstraint.constant = 0
//
//        request = MKLocalSearchRequest()
//        searchBar.showsCancelButton = false
//        searchBar.text = ""
//        searchText = ""
//        locationsearchTxt = ""
//        searchBar.resignFirstResponder()
//        if(selected_searchbar == "searchbar"){
//            self.locationtableView.isHidden = true
//        }
//        hideSearch()
        for subview in searchBar.subviews {
            for innerSubview in subview.subviews {
                if innerSubview is UITextField {
                    innerSubview.backgroundColor = UIColor(red:1, green:1, blue:1, alpha:1.0)
                    break
                }
            }
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
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
            
        }else{
            arrFilter.removeAll(keepingCapacity: false)
            self.arrCountry.removeAll()
            arrProjects = [String]()
            let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
            let array = (arrCountry as NSArray).filtered(using: searchPredicate)
            self.arrProjects = [String]()
            arrFilter = array as! [String]
            
            timer.invalidate()
            if(self.searchController.isActive){
                Apimanager.shared.stopAllSessions()
                self.loading = true
                self.allDownloaded = false
                self.from = 0
                self.filterProjects = [Project]()
                self.searchedProjects = [Project]()
                timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(searchProjects), userInfo: nil, repeats: false)
            }
        }
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
                print(i.placemark.coordinate.latitude)
                print(i.placemark.coordinate.longitude)
                self.arrCountry.append(i.placemark.name!)
            }
            if(self.tableViewTopConstraint.constant != 0){
                self.locationtableView.isHidden = false
                self.locationtableView.reloadData()
            }
        }
    }
    
}

//MARK: - Organization Filter Delegate
extension ProjectListViewController: ProjectFilterDelegate {
    func userDidSelectedFilter(changed: Bool, certificationsarray: NSMutableArray, ratingsarray: NSMutableArray, versionsarray: NSMutableArray, statesarray: NSMutableArray, countriesarray: NSMutableArray, countriesdict: NSMutableDictionary, statesdict: NSMutableDictionary, tagarray : NSMutableArray, totalCount: Int) {
        if(changed){
            self.tagarray = tagarray
            if(UserDefaults.standard.object(forKey: "tagdict") != nil){
                var keyed = NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "tagdict") as! Data) as! NSMutableDictionary
                //self.tags = (keyed.allKeys as! NSArray).mutableCopy() as! NSMutableArray
                self.selected_tags = [String]()
                var tempp = self.tagarray.mutableCopy() as! NSMutableArray
                tempp.remove("")
                for str in tempp{
                    var arr = keyed[str] as! [String]
                    for s in arr{
                        self.selected_tags.append(s)
                    }
                }
            }else{
                
            }
            self.countriesdict = countriesdict
            self.statesdict = statesdict
            self.loading = false
            self.statesarray = statesarray
            self.countriesarray = countriesarray
            self.certificationsarray = certificationsarray
            self.ratingsarray = ratingsarray
            self.versionsarray = versionsarray
            self.totalCount = totalCount
            //searchText = self.searchBar.text!
            pageNumber = 0
            loadType = "init"
            filterChanged = true
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
            self.projects = [Project]()
            //self.tableView.reloadData()
            
            DispatchQueue.main.async {            
                self.category = Payloads().makePayloadForProject(certificationsarray: certificationsarray, ratingsarray: ratingsarray, versionsarray: versionsarray, statesarray : tempstates, countriesarray : tempcountries)
                self.totalCount = totalCount
                    Apimanager.shared.stopAllSessions()
                    self.allDownloaded = false
                    self.from = 0
                    self.size = 500
                    self.projects = [Project]()
                    self.filterProjects = [Project]()
                    self.searchedProjects = [Project]()
                
                let tempcerts = certificationsarray
                let tempratings = ratingsarray
                let tempversions = versionsarray
                let tempstate = statesarray
                let tempcountry = tempcountries
                tempcerts.remove("")
                tempratings.remove("")
                tempversions.remove("")
                tempstate.remove("")
                tempcountry.remove("")
                if(tempcerts.count > 0 || tempratings.count > 0 || tempversions.count > 0 || tempstate.count > 0 || tempcountry.count > 0){
                    self.navigationItem.rightBarButtonItems = nil
                    self.makeNavigationBarButtons()
                    self.searchProjects()
                }else{
                    self.loadProjectsElasticUsingLocation(search: self.searchController.searchBar.text!, category: self.category, lat: self.currentPosition.target.latitude , lng: self.currentPosition.target.longitude, distance: self.queryingDistance)
                }
//
//                    if(self.searchController.isActive){
//
//
//                    }else if(self.searchBar.text!.count > 0){
//
//                    }else{
//                        self.loadProjectsElasticUsingLocation(search: self.searchController.searchBar.text!, category: self.category, lat: self.currentPosition.target.latitude , lng: self.currentPosition.target.longitude, distance: self.queryingDistance)
//                    }
                
            }
        }
    }
}


