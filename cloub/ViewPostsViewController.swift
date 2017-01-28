//
//  ClusterViewController.swift
//  cloub
//
//  Created by Chan Hee Park on 11/8/16.
//  Copyright © 2016 Chan Hee Park. All rights reserved.
//

import UIKit
import Firebase
class ViewPostsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, PostCellDelegate {
    var backendless = Backendless()
    var postsToDisplay: [Post]? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        self.collectionView?.register(PostCell.self, forCellWithReuseIdentifier: "PostCellId")
        self.collectionView?.refreshControl = UIRefreshControl()
        self.collectionView?.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    func refresh() {
        self.collectionView?.reloadData()
        self.collectionView?.refreshControl?.endRefreshing()
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.row
        let postCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCellId", for: indexPath) as! PostCell
        
        postCell.delegate = self
        
        if let postAtIndex = postsToDisplay?[index] {
            
            // here, we are inputting postId instead of post model
            //print("At viewPosts: \(postAtIndex)")
            postCell.fillContent(post: postAtIndex)
        }
        
        return postCell
        
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return (postsToDisplay?.count)!
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width + 210)
        }
        return CGSize(width: 0, height: 0)
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
    
    
    
}


