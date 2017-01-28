//
//  ViewController.swift
//  cloub
//
//  Created by Chan Hee Park on 10/19/16.
//  Copyright © 2016 Chan Hee Park. All rights reserved.
//

import UIKit
import MapKit

import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import GoogleMaps


class MainViewController: UIViewController {
    var userLocation: CLLocation?
    
    var geoPoints: [GeoPoint] = []
    var backendless = Backendless()
    var locationManager = CLLocationManager()
    var clusterManager: GMUClusterManager!
    var annotations: [PostAnnotation] = []
    var postIdAddedAlready: [String] = []
    var map: GMSMapView?
    
    
    var resultSearchController: UISearchController? = nil
    
    var postButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.backgroundColor = UIColor.white
        button.tintColor = UIColor.black
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = false
        button.clipsToBounds = false
        button.layer.shadowOpacity = 0.5
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 0)
        button.layer.shadowRadius = 3
        button.setImage(UIImage(named: "Camera.png"), for: .normal)
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationController?.navigationBar.isTranslucent = false
        self.view.backgroundColor = UIColor.white
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        
        backendless.userService.isValidUserToken({ (result) in
            print("isvalid")
            if let user = self.backendless.userService.currentUser {
                print(user.objectId)
            } else {
                self.handleLogout()
            }
            
            
        }, error: { fault in
            if let fault = fault {
                self.handleLogout()
                print(fault.message)
            }
        })
        
        setupGoogleMaps()
        setupSearchTable()
        setUpUserInterface()
        setupLocationManager()
        
    }
    
    func setupGoogleMaps() {
        let mapHeight = UIScreen.main.bounds.height - (self.tabBarController?.tabBar.frame.height)! - self.navigationController!.navigationBar.frame.height - UIApplication.shared.statusBarFrame.height
        print(mapHeight)
        self.map = GMSMapView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: mapHeight ))
        //let settings = GMSUISettings()
        map?.isMyLocationEnabled = true
        map?.settings.compassButton = true
        map?.settings.myLocationButton = true
        map?.settings.rotateGestures = false
        map?.delegate = self
        
        self.view.addSubview(map!)
        //map.translatesAutoresizingMaskIntoConstraints = false
        postButton.addTarget(self, action: #selector(takePicture), for: .touchUpInside)
        postButton.frame = CGRect(x: 10, y: self.map!.frame.height - 60, width: 50, height: 50)
        self.map?.addSubview(postButton)
        
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        //let renderer = GMUDefaultClusterRenderer(mapView: map!, clusterIconGenerator: iconGenerator)
        let renderer = CloubClusterRenderer(mapView: map!, clusterIconGenerator: iconGenerator)
        self.clusterManager = GMUClusterManager(map: map!, algorithm: algorithm, renderer: renderer)
        
    }
    
    func setUpUserInterface() {
        // Map View Setup
        
        
        // Search bar setup
        navigationItem.titleView = resultSearchController?.searchBar
        
        
        // post button
        
        
        
        
    }
    
    
    
    
    
    func handleLogout() {
        // Log out of facebook
        backendless.userService.logout({ (any) in
            FBSDKLoginManager().logOut()
            FBSDKAccessToken.setCurrent(nil)
            let vc = LoginViewController()
            self.present(vc, animated: true, completion: nil)
        }, error: { fault in
            FBSDKLoginManager().logOut()
            FBSDKAccessToken.setCurrent(nil)
            let vc = LoginViewController()
            self.present(vc, animated: true, completion: nil)
            print("error logging out")
        })
    }
}


