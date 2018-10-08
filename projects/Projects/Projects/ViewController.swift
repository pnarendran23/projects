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

class ViewController: UIViewController,UIGestureRecognizerDelegate, UITabBarDelegate {
    //"Schools","Offices","Retail","Case studies"
    let categories = ["Schools","Offices","Retail","Case studies","Schools","Offices","Retail","Case studies","Schools","Offices","Retail","Case studies","Schools","Offices","Retail","Case studies","Schools","Offices","Retail","Case studies","Schools","Offices","Retail","Case studies"]
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
    
    @IBOutlet weak var slideViewTopConstraint: NSLayoutConstraint!
    
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
        slideViewTopConstraint.constant = (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
        UIView.animate(withDuration: 1.0,
                       delay: 0.0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.0,
                       options: .curveEaseOut,
                       animations: {
                        self.navigationController?.navigationBar.barTintColor = UIColor.white
                        self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    
    func closeDrawer(){
        slideViewTopConstraint.constant = self.view.frame.size.height - self.tabbar.frame.size.height * 2
        UIView.animate(withDuration: 1.0,
                       delay: 0.0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.0,
                       options: .curveEaseOut,
                       animations: {
                        self.view.layoutIfNeeded()
                        self.navigationController?.navigationBar.barTintColor = UIColor.darkGray
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UINib.init(nibName: "exploreCell", bundle: nil), forCellWithReuseIdentifier: "explorecell")
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        tabbar.delegate = self
        self.slideUpView.isHidden = true
//        UISwipeGestureRecognizer(target: self, action: #selector(ViewController.swipeUp))
//        swipeUp.direction = UISwipeGestureRecognizerDirection.up
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
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        //loadProjectsElastic(search: "", category: "")
        bounds = GMSCoordinateBounds()
        mapView.delegate = self
        
        if(CLLocationManager.locationServicesEnabled()){
            self.locationManager.delegate = self
            self.locationManager.requestAlwaysAuthorization()
            self.mapView?.isMyLocationEnabled = true
            
            //Location Manager code to fetch current location
            self.locationManager.delegate = self
            self.locationManager.startUpdatingLocation()
            self.loadMapView()
        }else{
            print("Not allowed")
        }
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
        
        print(location.coordinate.latitude,location.coordinate.longitude)
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
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
                if(project.lat != " " && project.long != " "){
                    let item = ClusterItem(position: CLLocationCoordinate2DMake(Double(project.lat)!, Double(project.long)!), index: i)
                    clusterManager?.add(item)
                    bounds = bounds?.includingCoordinate(CLLocationCoordinate2DMake(Double(project.lat)!, Double(project.long)!))
                    i += 1
                }
            }
            clusterManager?.cluster()
            mapView.animate(with: GMSCameraUpdate.fit(bounds!, withPadding: 30.0))
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
            return false
        }else if (marker.userData is GMUStaticCluster){
            mapView.animate(toZoom: mapView.camera.zoom + 2.0)
        }
        return false
    }
}

extension ViewController: GMUClusterRendererDelegate {
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker){
        if marker.userData is ClusterItem{
            marker.icon = UIImage(named: "pin")
            marker.title = projects[(marker.userData as! ClusterItem).index].title
            marker.snippet = projects[(marker.userData as! ClusterItem).index].address.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "explorecell", for: indexPath) as! exploreCell
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if ( UI_USER_INTERFACE_IDIOM() == .pad ){
            return CGSize(width: collectionView.frame.size.width * 0.2, height: collectionView.frame.size.width * 0.3)
        }
        
        return CGSize(width: collectionView.frame.size.width * 0.4, height: collectionView.frame.size.width * 0.6)
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
        return UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if ( UI_USER_INTERFACE_IDIOM() == .pad ){
            return 20.0
        }
        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Select")
    }
    
    
    
    
    
}
