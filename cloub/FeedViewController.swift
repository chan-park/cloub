//
//  FeedViewController.swift
//  cloub
//
//  Created by Chan Hee Park on 10/20/16.
//  Copyright © 2016 Chan Hee Park. All rights reserved.
//

import UIKit
import MapKit

import FBSDKLoginKit
class FeedViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var locations:[FavoriteLocation] = []
    var initialLoad = true
    
    var backendless = Backendless()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        
        
        self.navigationItem.title = "Favorite Places"
        self.collectionView?.register(MapSnapShotCell.self, forCellWithReuseIdentifier: "MapSnapshot")
        NotificationCenter.default.addObserver(self, selector: #selector(favoritePlaceJustAdded), name: NSNotification.Name("FAVORITE_PLACE_ADDED"), object: nil)
        
        backendless.userService.isValidUserToken({ (result) in
            print("isvalid")
            if let user = self.backendless.userService.currentUser {
                self.updateUserIfNeeded(user)
            }
            
        }, error: { fault in
            if let fault = fault {
                self.handleLogout()
                print(fault.message)
            }
        })
        
    }
    
    func urlForGMSSnapshotAt(coordinate: CLLocationCoordinate2D) -> String {
        let lat = coordinate.latitude
        let long = coordinate.longitude
        let snapshotWidth = self.view.frame.width
        let snapshotHeight = 150
        let CLOUB_GOOGLE_MAPS_API_KEY = "AIzaSyAwwW5hvU8362MzWLv4GNxuKQGq-nwUviQ"
        
        let url = "https://maps.googleapis.com/maps/api/staticmap?center=\(lat),\(long)&zoom=14&scale=2&size=\(Int(snapshotWidth+1))x\(snapshotHeight)&key=\(CLOUB_GOOGLE_MAPS_API_KEY)"
        return url
    }
    
    func updateUserIfNeeded(_ user: BackendlessUser) {
        Types.tryblock({
            self.fetchData()
        }, catchblock: {(exception) in
            print("Server reported an error: \(exception as! Fault)")
        })
        
    }
    
    func fetchData() {
        let geoQuery = BackendlessGeoQuery(categories: ["favorite"])
        geoQuery?.metadata(["User.objectId": "\(self.backendless.userService.currentUser.objectId!)"])
        
        
        self.backendless.geoService.getPoints(geoQuery, response: { points in
            if let points = points {
                let geoPoints = points.data as! [GeoPoint]
                
                print("favorites")
                for eachGeoPoints in geoPoints {
                    let locationToAdd = FavoriteLocation(latitude: eachGeoPoints.latitude as CLLocationDegrees, longitude: eachGeoPoints.longitude as CLLocationDegrees)
                    //locationToAdd.addedTimestamp = eachGeoPoints.metadata?["timestamp"] as! Date?
                    self.locations.append(locationToAdd)
                }
                //self.locations.sort {($0.addedTimestamp as Double) < ($1.addedTimestamp as Double)}
                self.collectionView?.reloadData()
            }
        } , error: { fault in
            if let fault = fault {
                print(fault.message)
            }
        })
        
    }
    
    func favoritePlaceJustAdded(notification: NSNotification) {
        if let geoPoint = notification.userInfo?["place"] as? GeoPoint {
            let location = FavoriteLocation(latitude: geoPoint.latitude as CLLocationDegrees, longitude: geoPoint.longitude as CLLocationDegrees)
            //location.addedTimestamp = geoPoint.metadata["timestamp"] as! TimeInterval
            self.locations.append(location)
            //self.locations.sort {($0.addedTimestamp as Double) < ($1.addedTimestamp as Double)}
            self.collectionView?.reloadData()
        } else {
            print("error:: Favorite place just added could not be found")
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let locationToCheckout = self.locations[indexPath.row]
        let vc = FeedDetailViewController(collectionViewLayout: UICollectionViewFlowLayout())
        
        vc.location = locationToCheckout
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.locations.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: "MapSnapshot", for: indexPath) as! MapSnapShotCell
        let location = self.locations[indexPath.row]
        cell.location = location
        cell.updateNameOfPlaceAndPicture(urlString: urlForGMSSnapshotAt(coordinate: location.coordinate))
        // this translates coordinates to readable address, asynchronous
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    
    func handleLogout() {
        FBSDKLoginManager().logOut()
        FBSDKAccessToken.setCurrent(nil)
        backendless.userService.logout({ (any) in
            
            let vc = LoginViewController()
            self.present(vc, animated: true, completion: nil)
        }, error: { fault in
            let vc = LoginViewController()
            self.present(vc, animated: true, completion: nil)
            print("error logging out")
        })
    }
}


