//
//  MainTabBarController.swift
//  cloub
//
//  Created by Chan Hee Park on 10/20/16.
//  Copyright © 2016 Chan Hee Park. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let main = MainViewController()
        //let profile = ProfileViewController(collectionViewLayout: UICollectionViewFlowLayout())
        let layout = UICollectionViewFlowLayout()
        let profile = ViewMyProfileViewController(collectionViewLayout: layout)
        let feed = FeedViewController(collectionViewLayout: layout)
        
        let mainNav = UINavigationController(rootViewController: main)
        let feedNav = UINavigationController(rootViewController: feed)
        let profileNav = UINavigationController(rootViewController: profile)
        mainNav.navigationBar.tintColor = UIColor.black
        feedNav.navigationBar.tintColor = UIColor.black
        profileNav.navigationBar.tintColor = UIColor.black
        
        mainNav.tabBarItem.image = UIImage(named: "Globe.png")
        mainNav.tabBarItem.title = "Map"
        
        feedNav.tabBarItem.image = UIImage(named: "Marker.png")
        feedNav.tabBarItem.title = "Bookmark"
        profileNav.tabBarItem.image = UIImage(named: "User.png")
        profileNav.tabBarItem.title = "Profile"
        self.tabBar.tintColor = UIColor.black
        self.viewControllers = [mainNav, feedNav, profileNav]
        
    }

   

}
