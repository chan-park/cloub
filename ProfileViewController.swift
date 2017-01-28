//
//  ProfileViewController.swift
//  cloub
//
//  Created by Chan Hee Park on 10/20/16.
//  Copyright © 2016 Chan Hee Park. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase


class ProfileViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    // collectionView item array is going to look like below
    // profile cell -> photo cell ... 
    // i.e. 
    // item[0] = profile picture
    // item[1...] = photos
    
    var userCalledThisBlockAlready = false
    let profilePic = UIImageView()
    var photos:[UIImage?] = []
    
    
    // let photos:[UIImage] = [UIImage(named: "1.jpg")!, UIImage(named:"2.jpg")!, UIImage(named:"3.jpg")!, UIImage(named:"4.jpg")!, UIImage(named:"5.jpg")!, UIImage(named:"6.jpg")!, UIImage(named:"7.jpg")!, UIImage(named:"8.jpg")!, UIImage(named:"9.jpg")!, UIImage(named: "10.jpg")!, UIImage(named: "11.jpg")!, UIImage(named: "12.jpg")!, UIImage(named: "13.jpg")!]
    

    

    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.backgroundColor = UIColor.white
        self.collectionView?.register(ProfileCell.self, forCellWithReuseIdentifier: "profileCellId")
        self.collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCellId")
        // Do any additional setup after loading the view.
        

        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if user != nil {
                // User is signed in
                if self.userCalledThisBlockAlready == false {
                    self.emptyProfile()
                    self.fetchUserProfile()
                    self.userCalledThisBlockAlready = true
                }
            } else {
                // No user is signed in.
                self.handleLogout()
            }
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        self.navigationController?.navigationBar.isTranslucent = false
    }
    


    func emptyProfile() {
        // empty array (NEED OPTIMIZATION)
        photos = []
        profilePic.image = nil
        self.collectionView?.reloadData()
    }
    
    func downloadUrls(urls: [URL]) {
        self.photos = [UIImage?](repeating:nil, count: urls.count)
        for (i, url) in urls.enumerated() {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                if let error = error {
                    print(error)
                    return
                }
                DispatchQueue.main.async {
                    self.photos[i] = UIImage(data: data!)
                    self.collectionView?.reloadData()
                }
            }).resume()
        }
    }

    
    func fetchUserProfile() {
        // fetch user profile
        let uid = FIRAuth.auth()?.currentUser?.uid
        let ref = FIRDatabase.database().reference()
        var postUrls = [URL]()
        
//        ref.child("users").child(uid!).child("posts").queryOrdered(byChild: "timestamp").observe(.childAdded, with: {(snapshot) in
//            let postId = snapshot.key
//
//            ref.child("posts").child(postId).observeSingleEvent(of: .value, with: { (snapshot) in
//                if let urlString = snapshot.childSnapshot(forPath: "pictureUrl").value {
//                    let url = URL(string: urlString as! String)
//                    postUrls.append(url!)
//                    
//                }
//            })
//            
//        })
        
        
        
        
        ref.child("users").child(uid!).child("posts").queryOrdered(byChild: "timestamp").observe(.value, with: {(snapshot) in
            for child in snapshot.children.allObjects as! [FIRDataSnapshot] {
                let postId = child.key
                ref.child("posts").child(postId).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let urlString = snapshot.childSnapshot(forPath: "pictureUrl").value {
                        let url = URL(string: urlString as! String)
                        postUrls.append(url!)
                    }
                })
            }
            // When you finish appending, download those urls! 
        })
        
        
        
        ref.child("users").child(uid!).observeSingleEvent(of: .value, with: {
            (snapshot) in
            if let data = snapshot.value as? [String: Any] {
                self.navigationItem.title = data["username"] as? String
                // fetch profile picture if there is one
                if let profilePictureUrl = data["profileImageUrl"] {
                    // Display in the profile image view
                    let url = URL(string: profilePictureUrl as! String)
                    // Here you have to cache the image for less data usage
                    /**
                     *
                     *
                     *
                     */
                    
                    
                    // Download data at the specified 'url'
                    URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                        if let error = error {
                            print(error)
                            return
                        }
                        // DispatchQueue manages the execution of work items. Each work item submitted to a queue is processed on a pool of threads managed by the system
                        DispatchQueue.main.async {
                            //let cell = self.collectionView?.cellForItem(at: IndexPath(item: 0, section: 1)) as! ProfileCell
                            //cell.profileImage.image = UIImage(data: data!)
                            
                            self.profilePic.image = UIImage(data: data!)
                            self.collectionView?.reloadData()
                        }
                    }).resume()
                }
            }
        })
        
        
        
        
    }
    
    func seePost(sender: UIControlEvents) {
        
    }
    
    
    
    func handleLogout() {
        try! FIRAuth.auth()?.signOut()
        photos = []
        userCalledThisBlockAlready = false
        let loginViewController = LoginViewController()
        self.present(loginViewController, animated: true, completion: nil)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let itemNum = indexPath.row
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileCellId", for: indexPath) as! ProfileCell
            cell.profileImage.image = profilePic.image
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCellId", for: indexPath) as! PhotoCell
            cell.backgroundView = UIImageView(image: photos[itemNum])
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
            return photos.count
        }
        return 0
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            // return profile cell
            return CGSize(width: self.view.frame.width, height: 150)
        }
        let w = self.view.frame.width/3 - 1
        return CGSize(width: w, height: w)
    }
   
    // For spacing between photos
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
}


class ProfileCell: UICollectionViewCell{
    let profileImage: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = UIColor.green
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 40
        view.layer.masksToBounds = true
        view.clipsToBounds = true
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        setupViews()
    }
    
    func setupViews() {
        self.addSubview(profileImage)
        
        
        profileImage.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        profileImage.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 80).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        let seperator: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        self.addSubview(seperator)
        seperator.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        seperator.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        seperator.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



class PhotoCell: UICollectionViewCell{
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(label)
        //setupViews()
    }
    
    func setupViews() {
        self.backgroundColor = UIColor.red
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
