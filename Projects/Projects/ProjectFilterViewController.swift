//
//  DirectoryOrganizationFilterViewController.swift
//  USGBC
//
//  Created by Pradheep Narendran on 24/08/17.
//  Copyright © 2017 U.S Green Building Council. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

protocol ProjectFilterDelegate: class {
    func userDidSelectedFilter(changed: Bool, certificationsarray : NSMutableArray,ratingsarray : NSMutableArray, versionsarray : NSMutableArray, statesarray :NSMutableArray, countriesarray : NSMutableArray, countriesdict : NSMutableDictionary, statesdict : NSMutableDictionary, tagarray : NSMutableArray, totalCount : Int)
}

class ProjectFilterViewController: UIViewController {
    
    @IBAction func handleClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    var tagarray = NSMutableArray()
    var tags = NSMutableArray()
    var filter: String!
    fileprivate var filterChanged = false
    var actualstates = NSMutableArray()
    var countriesdict = NSMutableDictionary()
    var statesdict = NSMutableDictionary()
    var statesarray = NSMutableArray()
    var countriesarray = NSMutableArray()
    var states = NSMutableArray()
    var countries = NSMutableArray()
    var certificationsarray = NSMutableArray()
    var ratingsarray = NSMutableArray()
    var versionsarray = NSMutableArray()
    var certifications = NSMutableArray()
    var ratings = NSMutableArray()
    var versions = NSMutableArray()
    fileprivate var filters: [DirectoryProjectFilter] = []
    fileprivate var selectedIndexPath = IndexPath(row: 0, section: 0)
    weak var delegate: ProjectFilterDelegate?
    var totalCount = 0
    var selectedfilter : [String] = ["all","","","","",""]
    var all = 0, education = 0, homes = 0, roundtable = 0, members = 0, regions = 0
    
    @IBOutlet weak var clearFilterButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.tableView.separatorInset =  UIEdgeInsetsMake(0, 24, 0, 24)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        self.totalResultsLabel.font = UIFont.AktivGrotesk_Md(size: 14)
        self.clearFilterButton.titleLabel?.font = UIFont.AktivGrotesk_Md(size: 16)
        self.navigationController?.navigationBar.barTintColor = UIColor.white//hex(hex: Colors.primaryColor)
//        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white, kCTFontAttributeName : UIFont.gothamBook(size: 18) ] as [AnyHashable : NSObject]
//        navigationController?.navigationBar.titleTextAttributes = textAttributes as! [NSAttributedStringKey : Any]        
        
        
        
        if(UserDefaults.standard.object(forKey: "tagdict") != nil){
            var keyed = NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "tagdict") as! Data) as! NSMutableDictionary
            self.tags = (keyed.allKeys as! NSArray).mutableCopy() as! NSMutableArray
        }else{
            
        }
        self.totalResultsLabel.text = ""
        initViews()
        DispatchQueue.main.async {
            Utility.showLoading()
            self.loadFilters()
            self.loadProjectsMaxCount()
        }
        
    }
    @IBAction func handleclearfilter(_ sender: Any) {
        //selectedFilter = ""
        DispatchQueue.main.async {
            self.certificationsarray = NSMutableArray()
            self.ratingsarray = NSMutableArray()
            self.versionsarray = NSMutableArray()
            self.countriesarray = NSMutableArray()
            self.statesarray = NSMutableArray()
            self.tagarray = NSMutableArray()
            self.statesarray = NSMutableArray()
            
            self.certifications = NSMutableArray()
            self.ratings = NSMutableArray()
            self.versions = NSMutableArray()
            self.countries = NSMutableArray()
            self.states = NSMutableArray()
            self.filterChanged = true            
            Utility.showLoading()
            self.loadFilters()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProjectSubFilterViewController" {
            if let viewController = segue.destination as? ProjectFilterSubViewController {
                viewController.delegate = self
                print(sender)
                //viewController.filterString = selectedFilter.components(separatedBy: "+")
                if(self.certificationsarray.count == 0){
                    for i in self.certifications{
                        self.certificationsarray.add("")
                    }
                }
                if(self.versionsarray.count == 0){
                    for i in self.versions{
                        self.versionsarray.add("")
                    }
                }
                
                if(self.ratingsarray.count == 0){
                    for i in self.ratings{
                        self.ratingsarray.add("")
                    }
                }
                
                if(self.countriesarray.count == 0){
                    for i in self.countries{
                        self.countriesarray.add("")
                    }
                }
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
                if(sender as! Int == 2){
                    
                    var temp = self.countriesarray.mutableCopy() as! NSMutableArray
                    temp.remove("")
                    var temp_array = NSMutableArray()
                    if(temp.count > 0){
                        print(temp)
                        for i in temp{
                            var str = i as! String
                            var currentstate = ""
                            for (key,value) in countries{
                                if(str == value as! String){
                                    currentstate = key as! String
                                    break
                                }
                            }
                            
                            var states = countryjson["divisions"] as! [String : Any]
                            if(states[currentstate] != nil){
                                var state = states[currentstate] as! [String : Any]
                                for (key,value) in state{
                                    temp_array.add(value as! String)
                                }
                            }
                        }
                        self.states = temp_array
                        var tempstates = self.statesarray.mutableCopy() as!  NSMutableArray
                        tempstates.remove("")
                        if(tempstates.count == 0){
                            self.statesarray = NSMutableArray()
                            for i in temp_array{
                                self.statesarray.add("")
                            }
                        }
                        
                    }else{
                        var tempstates = self.statesarray.mutableCopy() as!  NSMutableArray
                        tempstates.remove("")
                        if(tempstates.count == 0){
                            self.statesarray = NSMutableArray()
                            for i in self.actualstates{
                                self.statesarray.add("")
                                self.states.add(i as! String)
                            }
                        }
                    }
                }
                if(self.tagarray.count == 0){
                    for i in self.tags{
                        self.tagarray.add("")
                    }
                }
                viewController.tagarray = tagarray                
                viewController.tags = tags
                viewController.countriesarray = self.countriesarray
                viewController.countries = self.countries
                viewController.statesarray = self.statesarray
                var swiftArray = self.states as AnyObject as! [String]
                var sortedArray = swiftArray.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
                self.states =  NSMutableArray.init(array: sortedArray)
                viewController.states = self.states
                viewController.certificationsarray = self.certificationsarray.mutableCopy() as! NSMutableArray
                viewController.ratingsarray = self.ratingsarray.mutableCopy() as! NSMutableArray
                viewController.versionsarray = self.versionsarray.mutableCopy() as! NSMutableArray
                viewController.certifications = self.certifications.mutableCopy() as! NSMutableArray
                viewController.versions = self.versions.mutableCopy() as! NSMutableArray
                viewController.ratings = self.ratings.mutableCopy() as! NSMutableArray
                if((sender as! Int) == 0){
                    viewController.title = "Certification Level"
                }else if((sender as! Int) == 3){
                    viewController.title = "Rating system"
                }else if((sender as! Int) == 4){
                    viewController.title = "Version"
                }else if((sender as! Int) == 2){
                    viewController.title = "State"
                }else if((sender as! Int) == 5){
                    viewController.title = "Tags"
                }
                else if((sender as! Int) == 1){
                    viewController.title = "Country"
                }
            }
        }
    }
    
    func initViews(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "filterselected", bundle: nil), forCellReuseIdentifier: "filterselected")
        tableView.register(UINib(nibName: "FilterCell", bundle: nil), forCellReuseIdentifier: "FilterCell")
        tableView.register(UINib(nibName: "SubFilterCell", bundle: nil), forCellReuseIdentifier: "SubFilterCell")
        tableView.tableFooterView = UIView()
    }
    var opened = false
    func loadFilters(){

        
        var group = DispatchGroup()
        //var objects = ["field_prjt_certification_level","field_prjt_rating_system_version","field_prjt_version", "field_prjt_country", "field_prjt_state"]
        var objects = ["certification_level.raw","rating_system_version.raw","add_country.raw","add_state.raw","rating_system.raw"]
        for i in objects{
            group.enter()
            Apimanager.shared.getProjectobjects(field_name : i, callback: { (dict, code) in
                if(code == -1 && dict != nil){
                    print(dict)
                    //self.authors.append(a["key"] as! String)
                    for arr in dict!{
                        var a = arr as! NSDictionary
                        var s = a["key"] as! String
                        s = s.replacingOccurrences(of: " ", with: "")
                        if(s != "" && s != "null"){
                        if(i == "certification_level.raw"){
                            var s = a["key"] as! String
                            self.certifications.add(a["key"] as! String)
                            var swiftArray = self.certifications as AnyObject as! [String]
                            var sortedArray = swiftArray.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
                            self.certifications = NSMutableArray()
                            for i in sortedArray{
                                self.certifications.add(i as! String)
                            }
                        }else if(i == "rating_system.raw"){
                            var s = a["key"] as! String
                            self.ratings.add(a["key"] as! String)
                            var swiftArray = self.ratings as AnyObject as! [String]
                            var sortedArray = swiftArray.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
                            self.ratings = NSMutableArray()
                            for i in sortedArray{
                                self.ratings.add(i as! String)
                            }
                        }else if(i == "add_country.raw"){
                            var s = a["key"] as! String
                            var arr = s.components(separatedBy: " [")
                            s = arr[0] as! String
                            if(arr.count == 1 && !self.countries.contains(s)){
                                self.countries.add(s)
                                self.countriesdict.setValue(a["key"] as! String, forKey: s)
                            }
                        }else if(i == "add_state.raw"){
                            var s = a["key"] as! String
                            var arr = s.components(separatedBy: " [")
                            s = arr[0] as! String
                            if(arr.count == 1 && !self.states.contains(s)){
                                self.actualstates.add(s)
                                self.statesdict.setValue(a["key"] as! String, forKey: s)
                            }
                        }else {
                            self.versions.add(a["key"] as! String)
                            var swiftArray = self.versions as AnyObject as! [String]
                            var sortedArray = swiftArray.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
                            self.versions = NSMutableArray()
                            for i in sortedArray{
                                self.versions.add(i as! String)
                            }
                        }
                        }
                    }
                    group.leave()
                }else if (code != -1 && dict == nil){
                    DispatchQueue.main.async {
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
                        group.leave()
                    }
                }
            })
        }
        group.notify(queue: .main) {
            var swiftArray = self.actualstates as AnyObject as! [String]
            var sortedArray = swiftArray.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
            self.actualstates =  NSMutableArray.init(array: sortedArray)
            
            swiftArray = self.countries as AnyObject as! [String]
            sortedArray = swiftArray.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
            self.countries =  NSMutableArray.init(array: sortedArray)
            if(sortedArray.index(of: "United States")! > -1){
                print(sortedArray.index(of: "United States")!)
                sortedArray.remove(at: sortedArray.index(of: "United States")!)
                sortedArray.insert("United States", at: 0)
                self.countries =  NSMutableArray.init(array: sortedArray)
            }
            self.loadProjectsMaxCount()
        }
        
    }
    var isloading = false
    func loadProjectsCount(){
        var tempstates = NSMutableArray()
        var tempcountries = NSMutableArray()
        var loopstates = NSMutableArray()
        let path = Bundle.main.path(forResource: "countries", ofType: "json")
        let jsonData = NSData(contentsOfFile:path!)
        var publications: [Publication] = []
        var localPublications: [Publication] = []
        var json = JSON()
        do{
            json = try JSON(data: jsonData as! Data)
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
        
        var dict = [[String : Any]]()
        dict = constructCategory()
        
        Apimanager.shared.getProjectsCount(category: dict) { count, code in
            if(code == -1 && count != nil){
                self.isloading = false
                Utility.hideLoading()
                if(dict.count == 0){
                    self.totalCount = count!
                }
                self.totalResultsLabel.text = "\(count!) of \(self.totalCount) Projects"
                self.tableView.reloadData()
            }else{
                self.isloading = false
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
    
    
    func loadProjectsMaxCount(){
        var dict = [[String : Any]]()
        Apimanager.shared.getProjectsCount(category: dict) { count, code in
            if(code == -1 && count != nil){
                DispatchQueue.main.async {
                    self.isloading = false
                    if(dict.count == 0){
                        self.totalCount = count!
                    }
                    self.loadProjectsCount()                    
                }
            }else{
                self.isloading = false
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
        }
    }
    
    @IBOutlet weak var totalResultsLabel: UILabel!
    @IBAction func handleDone(_ sender: Any){
        if(filterChanged){
            if let delegate = self.delegate {
                delegate.userDidSelectedFilter(changed: true, certificationsarray : certificationsarray,ratingsarray : ratingsarray, versionsarray : versionsarray, statesarray: statesarray, countriesarray: countriesarray, countriesdict: countriesdict, statesdict: statesdict, tagarray: tagarray,  totalCount:  totalCount)
            }
        }
        dismiss(animated: true, completion: nil)
    }
}

// MARK: UITableView delegates
extension ProjectFilterViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var temp = NSMutableArray()
        if(indexPath.row == 0){
            temp = self.certificationsarray
        }else if(indexPath.row == 3){
            temp = self.ratingsarray
        }else if(indexPath.row == 4){
            temp = self.versionsarray
        }else if(indexPath.row == 2){
            temp = self.statesarray
        }else if(indexPath.row == 5){
            temp = self.tagarray
        }else{
            temp = self.countriesarray
        }
        var t = temp.mutableCopy() as! NSMutableArray
        t.remove("")
        temp = t
        if(temp.count > 0){
            var str = temp.componentsJoined(by: ", ")
            let cell = tableView.dequeueReusableCell(withIdentifier: "filterselected") as! filterselected
            cell.detaillbl.numberOfLines = 0
            cell.separatorInset =  UIEdgeInsetsMake(0, 6, 0, 15)
            cell.lbl.textColor = UIColor(red:0.16, green:0.2, blue:0.23, alpha:1)
            cell.lbl.font = UIFont.AktivGrotesk_Md(size: 16)
            cell.detaillbl.textColor = UIColor(red:0.16, green:0.2, blue:0.23, alpha:1)
            cell.detaillbl.font = UIFont.AktivGrotesk_Rg(size: 13)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.accessoryType = .disclosureIndicator
            if(indexPath.row == 0){
                cell.lbl.text = "Certification Level"
            }else if(indexPath.row == 3){
                cell.lbl.text = "Rating system"
            }else if(indexPath.row == 4){
                cell.lbl.text = "Version"
            }else if(indexPath.row == 2){
                cell.lbl.text = "State"
            }else if(indexPath.row == 1){
                cell.lbl.text = "Country"
            }else if(indexPath.row == 5){
                cell.lbl.text = "Tags"
            }
            cell.detaillbl.text = str
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath) as! FilterCell
        cell.lbl.numberOfLines = 1
        cell.separatorInset =  UIEdgeInsetsMake(0, 6, 0, 15)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        if(indexPath.row == 0){
            cell.lbl.text = "Certification Level"
        }else if(indexPath.row == 3){
            cell.lbl.text = "Rating system"
        }else if(indexPath.row == 4){
            cell.lbl.text = "Version"
        }else if(indexPath.row == 2){
            cell.lbl.text = "State"
        }else if(indexPath.row == 1){
            cell.lbl.text = "Country"
        }else if(indexPath.row == 5){
            cell.lbl.text = "Tags"
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(tableView.cellForRow(at: indexPath) is FilterCell){
            var cell = tableView.cellForRow(at: indexPath) as! FilterCell
            //selectedFilter = cell.filterLabel.text!
        }else{
            var cell = tableView.cellForRow(at: indexPath) as! UITableViewCell
            //selectedFilter = (cell.textLabel?.text!)!
        }
        
        if(indexPath.row == 2){
            var temp = self.countriesarray.mutableCopy() as! NSMutableArray
            temp.remove("")
            if(temp.count > 0){
                performSegue(withIdentifier: "ProjectSubFilterViewController", sender: indexPath.row)
            }else{
                if(self.navigationController != nil){
                Utility.showToast(y: self.navigationController!.navigationBar.frame.size.height, message: "Please select the country first")
                }
            }
        }else{
            performSegue(withIdentifier: "ProjectSubFilterViewController", sender: indexPath.row)
        
        }
    }
}

extension ProjectFilterViewController: ProjectSubFilterDelegate {
    func userDidSelectedSubFilter(changed: Bool, certificationsarray: NSMutableArray, ratingsarray: NSMutableArray, versionsarray: NSMutableArray, statesarray: NSMutableArray, countriesarray: NSMutableArray, tagarray : NSMutableArray) {
        self.filterChanged = changed
        if(changed){
            self.tagarray = tagarray
            self.statesarray = statesarray
            self.countriesarray = countriesarray
            self.certificationsarray = certificationsarray
            self.versionsarray = versionsarray
            self.ratingsarray = ratingsarray
            self.tableView.reloadData()
            //self.searchText = self.searchBar.text!
            self.loadProjectsMaxCount()
            
        }
    }
    
    
}


