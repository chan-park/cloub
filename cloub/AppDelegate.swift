//
//  AppDelegate.swift
//  cloub
//
//  Created by Chan Hee Park on 10/19/16.
//  Copyright © 2016 Chan Hee Park. All rights reserved.
//



import UIKit
import Firebase
import FBSDKCoreKit
import GoogleMaps
import GooglePlaces
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let APP_ID = "1735BBC4-0DAF-5F98-FF61-193BDE9FDA00"
    let SECRET_KEY = "077984A7-5BC0-8868-FF5F-AA077E318A00"
    let VERSION_NUM = "v1"
    var backendless = Backendless.sharedInstance()
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FIRApp.configure()
        backendless?.initApp(APP_ID, secret: SECRET_KEY, version: VERSION_NUM)
        backendless?.userService.setStayLoggedIn(true)
        GMSServices.provideAPIKey("AIzaSyAwwW5hvU8362MzWLv4GNxuKQGq-nwUviQ")
        GMSPlacesClient.provideAPIKey("AIzaSyAwwW5hvU8362MzWLv4GNxuKQGq-nwUviQ")
        
        
        self.window?.rootViewController = MainTabBarController()
        self.window?.makeKeyAndVisible()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }
    
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
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
    }
    
    
}

