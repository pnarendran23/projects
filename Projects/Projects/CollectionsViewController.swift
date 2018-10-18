//
//  CollectionsViewController.swift
//  Projects
//
//  Created by Group X on 11/10/18.
//  Copyright © 2018 USGBC. All rights reserved.
//

import UIKit

class CollectionsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    let categories = ["Schools","Offices","Retail","Case studies","Schools","Offices","Retail","Case studies","Schools","Offices","Retail","Case studies","Schools","Offices","Retail","Case studies","Schools","Offices","Retail","Case studies","Schools","Offices","Retail","Case studies"]
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Collections"
        collectionView.register(UINib.init(nibName: "exploreGridCell", bundle: nil), forCellWithReuseIdentifier: "exploreGridCell")
        // Do any additional setup after loading the view.
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
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Select")
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let exploreViewController = sb.instantiateViewController(withIdentifier: "exploreViewController") as! exploreViewController
        exploreViewController.category = categories[indexPath.row]
        var viewcontrollers = self.navigationController?.viewControllers as! [UIViewController]
        viewcontrollers.append(exploreViewController)
        self.navigationController?.setViewControllers(viewcontrollers, animated: true)
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
