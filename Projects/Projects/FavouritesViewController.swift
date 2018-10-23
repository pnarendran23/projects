//
//  FavouritesViewController.swift
//  Projects
//
//  Created by Group X on 19/10/18.
//  Copyright © 2018 USGBC. All rights reserved.
//

import UIKit

protocol moreoption: class
{
    func moreOption(selected : String, index : Int)
}

class FavouritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {
    var favourites = [Project]()
    weak var mDelegate:moreoption?
    var isEdited = false
    var selected_project = Project()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(UINib(nibName: "ProjectCellwithImagemore", bundle: nil), forCellReuseIdentifier: "ProjectCellwithImagemore")
        tableView.register(UINib(nibName: "ProjectCellwithoutImagemore", bundle: nil), forCellReuseIdentifier: "ProjectCellwithoutImagemore")
        tableView.register(UINib(nibName: "FavouritesHeader", bundle: nil), forCellReuseIdentifier: "FavouritesHeader")
        tableView.register(UINib(nibName: "ListHeader", bundle: nil), forCellReuseIdentifier: "ListHeader")
       

        // Do any additional setup after loading the view.
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavouritesHeader") as! FavouritesHeader
        cell.label.text = "Projects(\(self.favourites.count))"
        if(isEdited == false){
            cell.button.setTitle("Edit", for: .normal)
        }else{
            cell.button.setTitle("Done", for: .normal)
        }
        cell.button.addTarget(self, action: #selector(self.editclicked(button:)), for: .touchUpInside )
        return cell
    }
    
    @objc func editclicked(button : UIButton){
        if(button.titleLabel?.text == "Edit"){
            isEdited = true
        }else if(button.titleLabel?.text == "Done"){
            isEdited = false
        }
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(UserDefaults.standard.object(forKey: "favourites") != nil){
            self.favourites = NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "favourites") as! Data) as! [Project]
            
          for i in self.favourites{
                print(i.node_id)
                print(i.ID)
                print(i.title)
                print(i.state)
            }
        }
        print(self.favourites.count)
        self.tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favourites.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let project = favourites[indexPath.row]
            project.address = project.address.components(separatedBy: "[").first!
            project.country = project.country.components(separatedBy: "[").first!
            project.state = project.state.components(separatedBy: "[").first!
            if(project.image.count > 0 && !project.image.contains("project_placeholder")){
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCellwithImagemore", for: indexPath) as! ProjectCellwithImagemore
                //cell.projectname.text = "\(project.title)"
                let normalText  = "\(project.title)"
                let attributedString = NSMutableAttributedString(string:normalText)
                var distance = ""
                if(isEdited == true){
                    tableView.isEditing = true
                    cell.more.isHidden = true
                }else{
                    tableView.isEditing = false
                    cell.more.isHidden = false
                }
                cell.more.tag = indexPath.row
                cell.more.addTarget(self, action: #selector(self.moreclicked(button:)), for: .touchUpInside)
                
                var boldText = "\n\(project.state), \(project.country)\n\(distance)"
                var mutableParagraphStyle = NSMutableParagraphStyle()
                // Customize the line spacing for paragraph.
                mutableParagraphStyle.lineSpacing = CGFloat(5)
                //bold.addAttribute(NSAttributedStringKey.paragraphStyle , value: mutableParagraphStyle, range: NSMakeRange(0, boldText.count))
                
                
                let attrs = [NSAttributedStringKey.font : cell.address.font] as [NSAttributedStringKey : Any]
                var boldString = NSMutableAttributedString(string: boldText, attributes:attrs)
                boldString.addAttribute(NSAttributedStringKey.paragraphStyle , value: mutableParagraphStyle, range: NSMakeRange(0, "\n\(project.state), \(project.country)".count))
                mutableParagraphStyle = NSMutableParagraphStyle()
                // Customize the line spacing for paragraph.
                mutableParagraphStyle.lineSpacing = CGFloat(15)
                
                boldString.addAttribute(NSAttributedStringKey.paragraphStyle , value: mutableParagraphStyle, range: NSMakeRange("\n\(project.state), \(project.country)".count, distance.count))
                attributedString.append(boldString)
                cell.projectname.attributedText = attributedString
                //cell.address.text = "\(project.address.replacingOccurrences(of: "\n", with: ""))"
                cell.project_image.center.y = cell.contentView.frame.size.height/2
                cell.project_image.sd_setImage(with: URL(string: project.image), placeholderImage: UIImage.init(named: "project_placeholder"))
                
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCellwithoutImagemore", for: indexPath) as! ProjectCellwithoutImagemore
                var saveButton = UIButton(type: .custom ) as UIButton
                saveButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                saveButton.addTarget(self, action: "accessoryButtonTapped:", for: .touchUpInside)
                saveButton.setImage(UIImage(named: "more"), for: .normal)
                //cell.accessoryView = saveButton as UIView
                if(isEdited == true){
                    tableView.isEditing = true
                    cell.more.isHidden = true
                }else{
                    tableView.isEditing = false
                    cell.more.isHidden = false
                }
                cell.more.addTarget(self, action: #selector(self.moreclicked(button:)), for: .touchUpInside)
                //cell.address.text = "\(project.address.replacingOccurrences(of: "\n", with: ""))"
                let normalText  = "\(project.title)"
                
                let attributedString = NSMutableAttributedString(string:normalText)
                
                var distance = ""
                
                var boldText = "\n\(project.state), \(project.country)\n\(distance)"
                var mutableParagraphStyle = NSMutableParagraphStyle()
                // Customize the line spacing for paragraph.
                mutableParagraphStyle.lineSpacing = CGFloat(5)
                //bold.addAttribute(NSAttributedStringKey.paragraphStyle , value: mutableParagraphStyle, range: NSMakeRange(0, boldText.count))
                
                
                let attrs = [NSAttributedStringKey.font : cell.address.font] as [NSAttributedStringKey : Any]
                var boldString = NSMutableAttributedString(string: boldText, attributes:attrs)
                boldString.addAttribute(NSAttributedStringKey.paragraphStyle , value: mutableParagraphStyle, range: NSMakeRange(0, "\n\(project.state), \(project.country)".count))
                mutableParagraphStyle = NSMutableParagraphStyle()
                // Customize the line spacing for paragraph.
                mutableParagraphStyle.lineSpacing = CGFloat(15)
                
                boldString.addAttribute(NSAttributedStringKey.paragraphStyle , value: mutableParagraphStyle, range: NSMakeRange("\n\(project.state), \(project.country)".count, distance.count))
                attributedString.append(boldString)
                cell.projectname.attributedText = attributedString
                //cell.projectname.attributedText = "\(project.title)\n\(project.address.replacingOccurrences(of: "\n", with: ""))"
                
                return cell
            }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    @objc func moreclicked(button : UIButton){
        selected_project = favourites[button.tag]
        var popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "morepopover") as! morepopoverViewController
        popoverContent.delegate = self
        var nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = UIModalPresentationStyle.popover
        var popover = nav.popoverPresentationController
        popoverContent.preferredContentSize = CGSize(width:200,height:90)
        popover?.delegate = self
        popover?.sourceView = button
        
        popover?.permittedArrowDirections = .up
        popover?.sourceRect = button.bounds
        self.present(nav, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var d = favourites[indexPath.row]
        if(isEdited == true){
            
        }else{
            self.performSegue(withIdentifier: "ProjectDetailsViewController", sender: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var rowaction = UITableViewRowAction()
       rowaction =  UITableViewRowAction.init(style: .destructive, title: "Delete", handler: {_,_ in
        print("Deleted")
            self.favourites.remove(at: indexPath.row)
            UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: self.favourites), forKey: "favourites")
            UserDefaults.standard.synchronize()
            self.tableView.reloadData()
        })
        if(rowaction.title == ""){
            tableView.endEditing(true)
        }
            return [rowaction]
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return isEdited
    }
    
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if(isEdited){
            return .delete
        }
        return .none
    }
    
  
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Favourites"
        self.navigationController?.navigationBar.tintColor = UIColor.black
        Apimanager.shared.stopAllSessions()   
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        //        self.navigationController?.navigationBar.isTranslucent = false
        //        self.navigationController?.navigationBar.barTintColor = UIColor.white
        //        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProjectDetailsViewController" {
            if let vc = segue.destination as? ProjectDetailsViewController {
                self.navigationItem.title = ""
                print(favourites[sender as! Int].node_id.count)
                if(favourites[sender as! Int].node_id != ""){
                    vc.node_id = favourites[sender as! Int].node_id
                    vc.projectID = favourites[sender as! Int].ID
                    vc.currentProject = favourites[sender as! Int]
                    let currentLocation = CLLocation.init(latitude: 38.904449, longitude: -77.046797)
                    vc.currentLocation = currentLocation
                    vc.navigationItem.title = vc.currentProject.title
                }
                //viewController.navigationItem.title = searchedProjects[sender as! Int].title
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
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
    
    @objc func direction(){
        print("Direction")
        var s =  selected_project.address
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
                var s = "saddr=&daddr=\(self.selected_project.lat),\(self.selected_project.long)"
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
        let url = URL.init(string: "\(Apimanager.shared.projectDetailsURL)/projects/\(selected_project.node_id)")
        
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



extension FavouritesViewController : moreoption {
    func moreOption(selected: String, index: Int) {
        if(index == 0){
            //Directions
            direction()
        }else if(index == 1){
            //Share
            share()
        }
    }
    
   

}
