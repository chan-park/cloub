//
//  MainViewControllerLocationHandlers.swift
//  cloub
//
//  Created by Chan Hee Park on 10/30/16.
//  Copyright © 2016 Chan Hee Park. All rights reserved.
//

import UIKit
import MapKit

import Firebase
import GoogleMaps

extension MainViewController: CLLocationManagerDelegate, UISearchControllerDelegate, UISearchBarDelegate, GMSMapViewDelegate {
    
    func setupLocationManager() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func setupSearchTable() {
        let locationSearchTable = LocationSearchTableViewController()
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        resultSearchController?.delegate = self
        resultSearchController?.searchBar.delegate = self
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
    }
    
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        clusterManager.cluster()
        let visibleRegion = mapView.projection.visibleRegion()
        let coordinateBounds = GMSCoordinateBounds(region: visibleRegion)
        let topRight = coordinateBounds.northEast
        let bottomLeft = coordinateBounds.southWest
        
        let p1 = GEO_POINT(latitude: topRight.latitude, longitude: bottomLeft.longitude)
        let p2 = GEO_POINT(latitude: bottomLeft.latitude, longitude: topRight.longitude)
        let query = BackendlessGeoQuery(rect: p1, southEast: p2, categories: ["post"])
        var dateComp = DateComponents()
        dateComp.hour = -12
        let halfDayAgo = Calendar.current.date(byAdding: dateComp, to: Date())
        let timestamp = halfDayAgo?.timeIntervalSince1970
        
        
        query?.includeMeta = true
        self.backendless.geoService.getPoints(query, response: { points in
            if let points = points {
                for geopoint in points.data {
                    let point = geopoint as! GeoPoint
                    
                    if let post = point.metadata["Post"] as? Post, let postId = post.objectId {
                        if self.postIdAddedAlready.contains(postId) == false {
                            self.postIdAddedAlready.append(postId)
                            print(self.postIdAddedAlready)
                            let annotation = PostAnnotation(position: CLLocationCoordinate2D(latitude: point.latitude as CLLocationDegrees, longitude: point.longitude as CLLocationDegrees), post: post)
                            
                            self.clusterManager.add(annotation)
                            self.clusterManager.cluster()
                        }
                        
                    }
                }
            }
            
        }, error: { fault in
            if let fault = fault {
                print(fault.message)
            }
        })
        
    }
   
    
    
    
    // MARK: - location manager delegate functions
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("user changed location authorization status")
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.userLocation = locations.last
        
        if let location = locations.last {
            self.map?.camera = GMSCameraPosition(target: location.coordinate, zoom: 14, bearing: 0, viewingAngle: 0)
            
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isEqual(mapView.userLocation) {
            let annotationView = mapView.view(for: mapView.userLocation)
            annotationView?.isEnabled = false
            annotationView?.canShowCallout = false
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let markerTapped = marker.userData as? PostAnnotation {
            // Marker is a single post
            let vc = ViewPostsViewController(collectionViewLayout: UICollectionViewFlowLayout())
            if let post = markerTapped.post {
                vc.postsToDisplay = [post]
                print(post)
            }
            
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            // Marker is a cluster
            let cluster = marker.userData as! GMUCluster
            let postAnnotations = cluster.items as! [PostAnnotation]
            let vc = ViewPostsViewController(collectionViewLayout: UICollectionViewFlowLayout())
            var postsToShow: [Post] = []
            for annotation in postAnnotations {
                if let post = annotation.post {
                    //print(post)
                    postsToShow.append(post)
                }
            }
            print(postsToShow)
            vc.postsToDisplay = postsToShow
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        // alert user to add star to favorite
        guard let user = self.backendless.userService.currentUser else {
            self.handleLogout()
            return
        }
        
        let p = GEO_POINT(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let timestamp = Date().timeIntervalSince1970
        let geoPoint = GeoPoint(point: p, categories: ["favorite"], metadata: ["User": user, "timestamp": timestamp])
        self.backendless.geoService.save(geoPoint, response: { geopoint in
            // add favorite marker to the map
            
            
            // alert feed controller
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FAVORITE_PLACE_ADDED"), object: nil, userInfo: ["place":geoPoint as Any])
        }, error: { fault in
            if let fault = fault {
                print(fault.message)
            }
        })
    }
    
    
}



