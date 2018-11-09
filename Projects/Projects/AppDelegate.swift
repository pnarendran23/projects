
//
//  AppDelegate.swift
//  Projects
//
//  Created by Group X on 07/10/18.
//  Copyright © 2018 USGBC. All rights reserved.
//

import UIKit
import GoogleMaps
import Crashlytics
import Fabric

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
let mapKey = "<key>"
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey(mapKey)
        // Override point for customization after application launch.
        Fabric.with([Crashlytics.self])
//        if(UserDefaults.standard.object(forKey: "downloaded") != nil){
//            if(UserDefaults.standard.object(forKey: "downloaded") as! Int == 1){
//                openApp()
//            }
//        }
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont.AktivGrotesk_Rg(size: 12)], for: .normal)
        
        
        //90,104,114
        UITabBar.appearance().tintColor = UIColor.init(red: 0.086, green: 0.466, blue: 0.729, alpha: 1)
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor.init(red: 0.086, green: 0.466, blue: 0.729, alpha: 1)], for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor(red:0.35, green:0.41, blue:0.45, alpha:1)], for: .normal)
        
        
        
        
        return true
    }
    
    
    func readFile() -> NSMutableArray{
        let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory , .userDomainMask , true).first!
        let documentsDirectoryPath = NSURL(string: documentsDirectoryPathString)!
        
        var jsonFilePath = documentsDirectoryPath.appendingPathComponent("test.json")
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        if !fileManager.fileExists(atPath: (jsonFilePath?.absoluteString)!, isDirectory: &isDirectory) {
            let created = fileManager.createFile(atPath: (jsonFilePath?.absoluteString)!, contents: nil, attributes: nil)
            if created {
                print("File created ")
            } else {
                print("Couldn't create file for some reason")
            }
        } else {
            print("File already exists")
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: (jsonFilePath?.absoluteString)!), options: .mappedIfSafe)
                print(data)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonRes = jsonResult as? NSArray {
                    // do stuff
                    return jsonRes.mutableCopy() as! NSMutableArray
                }
                
            } catch {
                // handle error
                return NSMutableArray()
            }
        }
        
        return NSMutableArray()
    }
    
    func openApp(){
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        var exampleViewController = mainStoryboard.instantiateViewController(withIdentifier: "initial")
        
        self.window?.rootViewController = exampleViewController
        
        self.window?.makeKeyAndVisible()

    }
    
    
    var orientationLock = UIInterfaceOrientationMask.portrait
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        if(UserDefaults.standard.object(forKey: "searchText") != nil){
            UserDefaults.standard.removeObject(forKey: "searchText")
        }
    }


}

