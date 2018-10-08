//
//  initialViewController.swift
//  Projects
//
//  Created by Group X on 08/10/18.
//  Copyright © 2018 USGBC. All rights reserved.
//

import UIKit

class initialViewController: UIViewController {
    @IBOutlet weak var progressView: UIProgressView!
    var projects = [Project]()
    var timer = Timer()
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            Utility.showLoading()
            self.progressView.setProgress(0, animated: false)
            self.loadProjectsElastic(search: "", category: "")
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadProjectsElastic(search: String, category: String){
        Apimanager.shared.getProjectsElasticForMap (from: 0, sizee: 50000, search: search, category: category, callback: {(totalRecords, projects, code) in
            if(code == -1 && projects != nil){
                self.projects = projects!                
                DispatchQueue.main.async {
                    Utility.hideLoading()
                   self.timer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(self.progress), userInfo: nil, repeats: true)
                }
                
            }else{
               
                
            }
        })
    }
    
    
    @objc func progress(){
        if(self.progressView.progress < 1.0){
            progressView.progress = progressView.progress + 0.025
        }else{
            timer.invalidate()
            print("Tik tok")
            var sb = UIStoryboard(name: "Main", bundle:nil)
            var MapView = sb.instantiateViewController(withIdentifier: "exploreViewController") as! ViewController
            MapView.projects = self.projects
            self.navigationController?.viewControllers[0] = MapView
        }
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
