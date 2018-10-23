//
//  morepopoverViewController.swift
//  Projects
//
//  Created by Group X on 20/10/18.
//  Copyright © 2018 USGBC. All rights reserved.
//

import UIKit

class morepopoverViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var delegate : moreoption?
    
    var options : [String] = ["Directions","Share"]
    var selected = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isScrollEnabled = false
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.register(UINib.init(nibName: "favouritesCell", bundle: nil), forCellReuseIdentifier: "favouritesCell")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "More"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if(selected != ""){
            delegate?.moreOption(selected: selected, index: options.index(of: selected)!)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected = options[indexPath.row]
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favouritesCell") as! favouritesCell
        cell.label.text = options[indexPath.row]
        if(indexPath.row == 0){
            cell.imageView?.image = UIImage.init(named: "Near_BU")
        }else if (indexPath.row == 1){
            cell.imageView?.image = UIImage.init(named: "share")
        }
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
