//
//  ViewProfileViewController.swift
//  cloub
//
//  Created by Chan Hee Park on 11/10/16.
//  Copyright © 2016 Chan Hee Park. All rights reserved.
//


import UIKit
import FBSDKLoginKit

class ViewProfileViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    // collectionView item array is going to look like below
    // profile cell -> photo cell ...
    // i.e.
    // item[0] = profile picture
    // item[1...] = photos
    
    var posts:[Post] = []
    var profilePic = UIImageView()
    var photoUrls:[String] = []
    var photos:[UIImageView]?
    var userId: String?
    var backendless = Backendless()
    var user:BackendlessUser? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.refreshControl = UIRefreshControl()
        self.collectionView?.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.collectionView?.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        self.collectionView?.register(ProfilePictureCell.self, forCellWithReuseIdentifier: "profileCellId")
        self.collectionView?.register(PostPictureCell.self, forCellWithReuseIdentifier: "photoCellId")
        
        
        self.posts = []
        Types.tryblock({
            self.fetchData()
        }, catchblock: {(exception) in
            print("Server reported an error: \(exception as! Fault)")
        })
        
    }
    

    
    func refresh() {
        self.collectionView?.reloadData()
        self.collectionView?.refreshControl?.endRefreshing()
    }
    
    
   
    
    func fillEachPostWithProfilePictureAndUsername() {
        guard let profileImage = self.profilePic.image else {
            return
        }
        for post in posts {
            post.profilePicture = profileImage
            post.username = self.navigationItem.title
        }
    }
    
    func fetchData() {
        // fetch profileImage
        if let user = self.user {
            if let url = user.getProperty("profile_picture_url") as? String {
                self.profilePic.sd_setImage(with: URL(string: url), completed: { (image, error, cachetype, url) in
                    if error != nil {
                        self.collectionView?.reloadData()
                    }
                })
            } else {
                print("This user doesn't have a profile picture")
            }
        }
        
        // fetch username
        if let user = self.user {
            self.navigationItem.title = user.getProperty("username") as! String?
        }
        
        
        // fetch posts
        if let user = self.user {
            let dataQuery = BackendlessDataQuery()
            dataQuery.whereClause = "writer.objectId = '\(user.getProperty("objectId")!)'"
            let queryOption = QueryOptions()
            queryOption.sort(by: ["created DESC"])
            dataQuery.queryOptions = queryOption
            backendless.data.of(Post.self).find(dataQuery, response: { (collection) in
                if let collection = collection {
                    self.posts = collection.data as! [Post]
                    self.fillEachPostWithProfilePictureAndUsername()
                    self.collectionView?.reloadData()
                }
            }, error: { (fault) in
                if let fault = fault {
                    print(fault.message)
                }
            })
            
            
            
            
        }
        
        
    }
    
    
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let itemNum = indexPath.row
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileCellId", for: indexPath) as! ProfilePictureCell
            cell.profileImage.image = profilePic.image
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCellId", for: indexPath) as! PostPictureCell
            cell.imageView.image = nil
            if let url = posts[itemNum].mediumSizeImageUrl {
                //cell.imageView.loadImageUsingCacheWithString(urlString: url, completionHandler: nil)
                cell.imageView.sd_setImage(with: URL(string: url), placeholderImage: nil)

            }
            cell.clipsToBounds = true
            cell.backgroundView?.contentMode = .scaleAspectFill
            return cell
        }
        
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(section)
        if section == 0 {
            return 1
        } else if section == 1 {
            return posts.count
        }
        return 0
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        collectionView.collectionViewLayout.invalidateLayout()
        return 2
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var w: CGFloat?
        var h: CGFloat?
        if indexPath.section == 0 {
            // return profile cell
            w = self.view.frame.width
            h = 150
        } else if indexPath.section == 1{
            // for first and third width - 1, middle stay the same
            w = self.view.frame.width/3.0 - 0.5
            h = self.view.frame.width/3.0 - 0.5
            
        }
        
        return CGSize(width: w!, height: h!)
        
        
    }
    
    // For spacing between photos
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.2, left: 0, bottom: 0.2, right: 0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let postToView = self.posts[indexPath.row]
            let vc = ViewPostsViewController(collectionViewLayout: UICollectionViewFlowLayout())
            vc.postsToDisplay = [postToView]
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func handleLogout() {
        backendless.userService.logout({ (any) in
            FBSDKLoginManager().logOut()
            FBSDKAccessToken.setCurrent(nil)
            let vc = LoginViewController()
            self.present(vc, animated: true, completion: nil)
        }, error: { fault in
            print("error logging out")
        })
    }
}

