//
//  FeedDetailViewController.swift
//  cloub
//
//  Created by Chan Hee Park on 10/23/16.
//  Copyright © 2016 Chan Hee Park. All rights reserved.
//

import UIKit
import MapKit
class FeedDetailViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, PostCellDelegate {
    var location: CLLocation?
    var backendless = Backendless()
    var posts:[Post] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.backgroundColor = UIColor.white
        self.collectionView?.register(PostCell.self, forCellWithReuseIdentifier: "post")
        // Do any additional setup after loading the view.
        
        retrievePostAroundThisLocation()
    }
    
    func addPlaceHolderImageForNoPost() {
        
        print("PLACE HOLDER!")
        let label = UILabel()
        label.text = "No Post Here :("
        label.textColor = UIColor(r: 220, g: 220, b: 220)
        
        label.textAlignment = .center
        label.useSFUIFont(withSize: 20, andStyle: "thin")
        label.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        label.heightAnchor.constraint(equalToConstant: 100).isActive = true
        label.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
    }
    
    
    func retrievePostAroundThisLocation() {
        guard let location = self.location else {
            return
        }
        
        let GEOPOINT = GEO_POINT(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        let geoQuery = BackendlessGeoQuery(point: GEOPOINT, radius: 30, units: METERS, categories: ["post"])
        geoQuery?.pageSize = 5 // first
        geoQuery?.includeMeta = true
        self.backendless.geoService.getPoints(geoQuery, response: { points in
            
            if let points = points {
                if points.data.isEmpty {
                    self.addPlaceHolderImageForNoPost()
                }
                let geoPoints = points.data as! [GeoPoint]
                for geoPoint in geoPoints {
                    if let relatedPost = geoPoint.metadata["Post"] as? Post {
                        self.posts.append(relatedPost)
                    }
                }
                self.collectionView?.reloadData()
            }
        }, error: { fault in
            if let fault = fault {
                print(fault.message)
            }
        })
        
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func didSelectProfile(uid: String) {
        Types.tryblock({
            let query = BackendlessDataQuery()
            query.whereClause = "objectId = '\(uid)'"
            if let collection = self.backendless.data.of(BackendlessUser.ofClass()).find(query) {
                let user = collection.data.first as! BackendlessUser
                let profileViewToShow = ViewProfileViewController(collectionViewLayout: UICollectionViewFlowLayout())
                profileViewToShow.user = user
                self.navigationController?.pushViewController(profileViewToShow, animated: true)
            }
            
        }, catchblock: { exception in
            print("Backendless server error:: cannot fetch user object:: \(exception as! Fault)")
        })
    }
    
    func didLikePost(postId: String, completionHandler: @escaping ()->()) {
        self.backendless.data.of(Post.self).findID(postId, response: { (result: Any!) -> Void in
            let post = result as! Post
            let dataQuery = BackendlessDataQuery()
            dataQuery.whereClause = "objectId = '\(postId)' AND peopleWhoLikedIt.objectId = '\(self.backendless.userService.currentUser.objectId!)'"
            print(dataQuery.whereClause)
            self.backendless.data.of(Post.self).find(dataQuery, response: { (collection) in
                if let collection = collection {
                    if collection.data.isEmpty {
                        print("liked!!")
                        post.likes = post.likes + 1
                        post.peopleWhoLikedIt = [self.backendless.userService.currentUser]
                        self.backendless.data.of(Post.self).save(post)
                    } else {
                        print("already liked")
                    }
                }
            }, error: { (fault) in
                if let fault = fault  {
                    print(fault.message)
                }
            })
            completionHandler()
        }, error: { fault in
            if let fault = fault {
                print(fault.message)
            }
        })
        
        
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width + 160.0)
        }
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "post", for: indexPath) as! PostCell
        cell.delegate = self
        cell.fillContent(post: posts[indexPath.row])
        return cell
    }
}
