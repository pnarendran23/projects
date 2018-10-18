//
//  CourseSubFilterViewController.swift
//  USGBC
//
//  Created by Pradheep Narendran on 21/08/17.
//  Copyright © 2017 U.S Green Building Council. All rights reserved.
//

import UIKit

protocol ProjectSubFilterDelegate: class {
    func userDidSelectedSubFilter(changed: Bool, certificationsarray : NSMutableArray,ratingsarray : NSMutableArray, versionsarray : NSMutableArray, statesarray :NSMutableArray, countriesarray : NSMutableArray, tagarray : NSMutableArray)
}

class ProjectFilterSubViewController: UIViewController {
    var tagarray = NSMutableArray()
    var tags = NSMutableArray()
    var countriesarray = NSMutableArray()
    var statesarray = NSMutableArray()
    var countries = NSMutableArray()
    var states = NSMutableArray()    
    var certificationsarray = NSMutableArray()
    var ratingsarray = NSMutableArray()
    var versionsarray = NSMutableArray()
    var certifications = NSMutableArray()
    var ratings = NSMutableArray()
    var versions = NSMutableArray()
    var filter:ProjectFilter!
    weak var delegate: ProjectSubFilterDelegate?
    fileprivate var filterChanged = false
    var selectedIndexPath = IndexPath(row: 0, section: 0)
    var filterString: [String] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.keyboardDismissMode = .onDrag
        initViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.topViewController?.navigationItem.rightBarButtonItem?.isEnabled = true
        AWBanner.hide()
    }
    
    func initViews(){
        //title = filter.name
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SubFilterCell", bundle: nil), forCellReuseIdentifier: "SubFilterCell")
        tableView.tableFooterView = UIView()
        print(filter)
        
    }
    
    @IBAction func hanldeApply(){
        if(filterChanged){
            if let delegate = self.delegate {
                delegate.userDidSelectedSubFilter(changed: filterChanged, certificationsarray : certificationsarray,ratingsarray : ratingsarray, versionsarray : versionsarray,statesarray: statesarray, countriesarray:  countriesarray, tagarray: tagarray)
            }
        }
        navigationController?.popViewController(animated: true)
    }
}

// MARK: UITableView delegates
extension ProjectFilterSubViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(title == "Certification Level"){
            return self.certifications.count
        }else if(title == "Rating system"){
            return self.ratings.count
        }else if(title == "Version"){
            return self.versions.count
        }else if(title == "State"){
            return self.states.count
        }else if(title == "Tags"){
            return self.tagarray.count
        }
        else {
            return self.countries.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubFilterCell", for: indexPath) as! SubFilterCell
        cell.selectionStyle = .none
        cell.tintColor = UIColor.black
        var arr = NSMutableArray()
        var arr1 = NSMutableArray()
        if(title == "Certification Level"){
            arr = self.certificationsarray
            arr1 = self.certifications
        }else if(title == "Rating system"){
            arr = self.ratingsarray
            arr1 = self.ratings
        }else if(title == "Version"){
            arr = self.versionsarray
            arr1 = self.versions
        }else if(title == "State"){
            arr = self.statesarray
            arr1 = self.states
        }else if(title == "Tags"){
            arr = self.tagarray
            arr1 = self.tags
        }
        else if(title == "Country"){
            arr = self.countriesarray
            arr1 = self.countries
        }//else if(filter.name == "Course format"){
        //            arr = self.formatarray
        //        }else if(filter.name == "Course level"){
        //            arr = self.levelarray
        //        }else{
        //            arr = self.languagearr
        //        }
        if(arr1.contains(arr[indexPath.row])){
            cell.accessoryType = .checkmark
            selectedIndexPath = indexPath
        }else{
            cell.accessoryType = .none
        }
        cell.subFilterLabel.text = arr1[indexPath.row] as! String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        filterChanged = true
        
        if(title == "Certification Level"){
            let cell = tableView.cellForRow(at: indexPath) as! SubFilterCell
            if (cell.accessoryType == .checkmark){
                //filter.subFilters[selectedIndexPath.row].selected = false
                self.certificationsarray.replaceObject(at: indexPath.row, with: "")
                cell.accessoryType = .none
            }else if (cell.accessoryType == .none){
                cell.accessoryType = .checkmark
                //filter.subFilters[indexPath.row].selected = true
                self.certificationsarray.replaceObject(at: indexPath.row, with: certifications[indexPath.row])
            }
            selectedIndexPath = indexPath
        }else if(title == "State"){
            let cell = tableView.cellForRow(at: indexPath) as! SubFilterCell
            if (cell.accessoryType == .checkmark){
                //re[selectedIndexPath.row].selected = false
                self.statesarray.replaceObject(at: indexPath.row, with: "")
                cell.accessoryType = .none
            }else if (cell.accessoryType == .none){
                cell.accessoryType = .checkmark
                //filter.subFilters[indexPath.row].selected = true
                self.statesarray.replaceObject(at: indexPath.row, with: states[indexPath.row])
            }
            selectedIndexPath = indexPath
        }else if(title == "Tags"){
            let cell = tableView.cellForRow(at: indexPath) as! SubFilterCell
            if (cell.accessoryType == .checkmark){
                //re[selectedIndexPath.row].selected = false
                self.tagarray.replaceObject(at: indexPath.row, with: "")
                cell.accessoryType = .none
            }else if (cell.accessoryType == .none){
                cell.accessoryType = .checkmark
                //filter.subFilters[indexPath.row].selected = true
                self.tagarray.replaceObject(at: indexPath.row, with: tags[indexPath.row])
            }
            selectedIndexPath = indexPath
        }else if(title == "Country"){
            self.statesarray = NSMutableArray()
            for i in states{
                self.statesarray.add("")
            }
            let cell = tableView.cellForRow(at: indexPath) as! SubFilterCell
            if (cell.accessoryType == .checkmark){
                //re[selectedIndexPath.row].selected = false
                self.countriesarray.replaceObject(at: indexPath.row, with: "")
                cell.accessoryType = .none
            }else if (cell.accessoryType == .none){
                cell.accessoryType = .checkmark
                //filter.subFilters[indexPath.row].selected = true
                self.countriesarray.replaceObject(at: indexPath.row, with: countries[indexPath.row])
            }
            selectedIndexPath = indexPath
        }else if(title == "Rating system"){
            let cell = tableView.cellForRow(at: indexPath) as! SubFilterCell
            if (cell.accessoryType == .checkmark){
                //re[selectedIndexPath.row].selected = false
                self.ratingsarray.replaceObject(at: indexPath.row, with: "")
                cell.accessoryType = .none
            }else if (cell.accessoryType == .none){
                cell.accessoryType = .checkmark
                //filter.subFilters[indexPath.row].selected = true
                self.ratingsarray.replaceObject(at: indexPath.row, with: ratings[indexPath.row])
            }
            selectedIndexPath = indexPath
        }else{
            let cell = tableView.cellForRow(at: indexPath) as! SubFilterCell
            if (cell.accessoryType == .checkmark){
                //re[selectedIndexPath.row].selected = false
                self.versionsarray.replaceObject(at: indexPath.row, with: "")
                cell.accessoryType = .none
            }else if (cell.accessoryType == .none){
                cell.accessoryType = .checkmark
                //filter.subFilters[indexPath.row].selected = true
                self.versionsarray.replaceObject(at: indexPath.row, with: versions[indexPath.row])
            }
            selectedIndexPath = indexPath
        }
        
        
    }
}




