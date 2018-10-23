//
//  initialViewController.swift
//  Projects
//
//  Created by Group X on 08/10/18.
//  Copyright © 2018 USGBC. All rights reserved.
//

import UIKit
import SwiftyJSON

class initialViewController: UIViewController{
    var allDownloaded = false
    let fileManager = FileManager.default
    var from = 0
    var totalRecords = 0
    var size = 5000
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    
    var projectsURL = "https://elastic:dhLMyQUY4ZnDXVl3qIBDGS4P@b4eac287a05e468b934969945bb6b223.us-east-1.aws.found.io:9243/projects/_search?"
    var projectsArray = NSMutableArray()
    override func viewDidLoad() {

        from = 0
        projectsArray = NSMutableArray()
        let str = "District of Columbia"
        print(str.components(separatedBy: "[").first!)
        DispatchQueue.main.async {
            //self.getData(from: self.from)
        }
    }
    
    var isDirectory: ObjCBool = false
    
    func getData(from : Int){
        if(!allDownloaded){
            Apimanager.shared.getProjectsElasticForMapNewOnce(from: from, sizee: size, search: "", category: "", lat: 0, lng: 0, distance: 0, callback: {(totalRecords, projects, code) in
                if(code == -1 && projects != nil){
                    self.totalRecords = totalRecords!
                    //self.projectsArray = projects!
                    DispatchQueue.main.async {
                        if(projects!.count > 0){
                            self.from = self.from + projects!.count
                            
                            for i in projects!{
                                self.progressView.setProgress(Float(self.from)/Float(self.totalRecords), animated: true)
                                self.progressLabel.text = "Downloading Projects (\(self.from)/\(self.totalRecords))"
                                var dict = NSMutableDictionary()
                                dict["title"] = i.title
                                dict["country"] = i.country
                                dict["address"] = i.address
                                dict["node_id"] = i.node_id
                                dict["state"] = i.state
                                dict["certification_level"] = i.certification_level
                                dict["lat"] = i.lat
                                dict["long"] = i.long
                                self.projectsArray.add(dict)
                            }
                            self.writeFile(array: JSON(self.projectsArray))
                        }else{
                            self.allDownloaded = true
                            UserDefaults.standard.set(1, forKey: "downloaded")
                            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            var exampleViewController = mainStoryboard.instantiateViewController(withIdentifier: "initial")
                            
                            UIApplication.shared.keyWindow?.rootViewController = exampleViewController
                            UIApplication.shared.keyWindow?.makeKeyAndVisible()
                            
                        }
                    }
                }else{
                    
                }
            })
        }
    }
    
    func writeFile(array : JSON){
        let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory , .userDomainMask , true).first!
        let documentsDirectoryPath = NSURL(string: documentsDirectoryPathString)!
        
        var jsonFilePath = documentsDirectoryPath.appendingPathComponent("test.json")
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        
        // creating a .json file in the Documents folder
        if !fileManager.fileExists(atPath: (jsonFilePath?.absoluteString)!, isDirectory: &isDirectory) {
            let created = fileManager.createFile(atPath: (jsonFilePath?.absoluteString)!, contents: nil, attributes: nil)
            if created {
                print("File created ")
            } else {
                print("Couldn't create file for some reason")
            }
        } else {
            print("File already exists")
                AppDelegate().readFile()
        }
        
        // creating an array of test data
        // creating JSON out of the above array

        // Write that JSON to the file created earlier
        jsonFilePath = documentsDirectoryPath.appendingPathComponent("test.json")
        do {
            
            let storage = array.description
            let jsonData = storage.data(using: String.Encoding.utf8)!
            let file = try FileHandle(forWritingTo: jsonFilePath!)
            file.write(jsonData)
            print("JSON data was written to teh file successfully!")
            DispatchQueue.main.async {
                self.getData(from: self.from)
            }
        } catch let error as NSError {
            print("Couldn't write to file: \(error.localizedDescription)")
        }
    }
    
    
    
}
