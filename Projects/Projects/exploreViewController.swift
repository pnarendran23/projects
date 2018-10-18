//
//  exploreViewController.swift
//  Projects
//
//  Created by Group X on 09/10/18.
//  Copyright © 2018 USGBC. All rights reserved.
//

import UIKit

class exploreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var category = ""
    var projects = ["USGBC","Promantus","Group10","USGBC","Promantus","Group10","USGBC","Promantus","Group10","USGBC","Promantus","Group10"]
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib.init(nibName: "exploreCellDecorate", bundle: nil), forCellReuseIdentifier: "exploreCellDecorate")
        
        tableView.register(UINib.init(nibName: "exploreCell", bundle: nil), forCellReuseIdentifier: "exploreCell")
        
        
        // Do any additional setup after loading the view.
    }
    
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == 0){
            return 285
        }
        return 44//320
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "exploreCellDecorate", for: indexPath) as! exploreCellDecorate
                cell.categoryname.text = "\(category)"
                cell.counts.text = "\(projects.count) Projects"
            return cell
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "exploreCell", for: indexPath) as! exploreCell
        cell.textLabel?.text = projects[indexPath.row - 1]
        cell.detailTextLabel?.text = ".7 mi."
        return cell
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
