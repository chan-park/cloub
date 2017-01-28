//
//  PostCell.swift
//  cloub
//
//  Created by Chan Hee Park on 11/11/16.
//  Copyright © 2016 Chan Hee Park. All rights reserved.
//


import UIKit
import MapKit

protocol PostCellDelegate {
    func didSelectProfile(uid: String) -> Void
    func didLikePost(postId: String, completionHandler: @escaping ()->()) -> Void
}

// MARK : - PostCell

class PostCell: UICollectionViewCell {
    private let PROFILE_PIC_HEIGHT:CGFloat = 40
    
    var backendless = Backendless()
    var post: Post?
    var delegate: PostCellDelegate!
    var userProfilePicture: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 40/2
        view.layer.masksToBounds = true
        view.image = UIImage(named: "profile_place_holder.png")
        return view
    }()
    
    var usernameField: UILabel = {
        let label = UILabel()
        label.useSFUIFont(withSize: 15, andStyle: "bold")
        label.backgroundColor = UIColor.clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var headerContainer: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        
        return view
    }()
    
    var pictureView: UIImageView = {
        let view = UIImageView()
        view.isUserInteractionEnabled = true
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var footerContainer: UIView = {
        let view = UIImageView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    
    var locationField: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.clear
        label.textAlignment = .center
        //label.textColor = UIColor(r: 150, g: 150, b: 150)
        label.useSFUIFont(withSize: 10, andStyle: "black")
        
        return label
    }()
    
    var captionField: UITextView = {
        let view = UITextView()
        view.backgroundColor = UIColor.white
        view.font = UIFont(name: "SFUIDisplay-Black", size: 20)
        view.textAlignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isScrollEnabled = false
        return view
    }()
    
    var likeContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var likeImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        
        return imageView
    }()
    
    var numberOfLikes: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.useSFUIFont(withSize: 15, andStyle: "bold")
        return label
    }()
    
    var likeView: UIImageView = {
        let view = UIImageView()
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(named: "UpArrowWhite.png")
        
        return view
    }()
    override init(frame: CGRect) {
        super.init(frame:frame)
        
        setupViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        //self.userProfilePicture.image = nil
        self.usernameField.text = nil
        self.pictureView.image = nil
        super.prepareForReuse()
        //self.userProfilePicture.image = UIImage(named: "profile_place_holder.png")
        
    }
    
    func fillContent(post: Post) {
        self.post = post
        // writer profile picture
        Types.tryblock({
            if let profilePic = self.post?.profilePicture {
                self.userProfilePicture.image = profilePic
            }
            if let username = self.post?.username {
                self.usernameField.text = username
            }
            
            let query = BackendlessDataQuery()
            query.whereClause = "objectId = '\(post.writerId!)'"
            self.backendless.userService.find(byId: post.writerId!, response: { (user) in
                
                if let user = user, let url = user.getProperty("profile_picture_url") as? String {
                    if self.userProfilePicture.image == UIImage(named: "profile_place_holder.png") {
                        
                        // if not already loaded
                        //self.userProfilePicture.loadImageUsingCacheWithString(urlString: url, completionHandler: nil)
                        self.userProfilePicture.sd_setImage(with: URL(string: url), completed: { (image, error, cacheType, url) in
                            post.profilePicture = image
                        })
                    }
                }
                if let user = user, let username = user.getProperty("username") as? String {
                    if self.usernameField.text == nil {
                        // if not already loaded
                        self.usernameField.text = username
                        post.username = username
                    }
                    
                }
            }, error: { (fault) in
                if let fault = fault {
                    print(fault.message)
                }
            })
            
            
            
            // pictureView
            if let pictureUrl = post.largeSizeImageUrl {
                print("start")
                //self.pictureView.loadImageUsingCacheWithString(urlString: pictureUrl, completionHandler: nil)
                self.pictureView.sd_setImage(with: URL(string: pictureUrl), placeholderImage: nil)
                
            }
            
            // caption
            if let caption = post.caption {
                self.captionField.text = caption
            }
            
            // likes
            
            self.numberOfLikes.text = "\(post.likes)"
            
            // location
            let geoQuery = BackendlessGeoQuery(categories: ["post"])
            geoQuery?.whereClause = "Post.objectId = '\(post.objectId!)'"
            geoQuery?.pageSize(1)
            self.backendless.geoService.getPoints(geoQuery, response: { (points) in
                if let points = points {
                    print("comes here")
                    if let point = points.data.first as? GeoPoint {
                        let location = CLLocation(latitude: point.latitude as CLLocationDegrees, longitude: point.longitude as CLLocationDegrees)
                        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                            let placemark = placemarks?[0]
                            let city = placemark?.addressDictionary?["City"]
                            let country = placemark?.addressDictionary?["Country"]
                            if let city = city, let country = country {
                                self.locationField.text = "At \(city), \(country)"
                            } else {
                                print("error at location Geocoder")
                            }
                        })
                    }
                }
            }, error: { (fault) in
                if let fault = fault {
                    print(fault.message)
                }
            })
            
            
            
        }, catchblock: {(exception) in
            print("Backendless server error: \(exception as! Fault)")
            
        })
        
        
        
        
        
        
        
        
        
    }
    
    
    
    func setupViews() {
        let separator1: UIView = {
            let separator = UIView()
            separator.translatesAutoresizingMaskIntoConstraints = false
            separator.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
            return separator
        }()
        // header
        self.addSubview(headerContainer)
        headerContainer.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        headerContainer.heightAnchor.constraint(equalToConstant: PROFILE_PIC_HEIGHT + 10.0).isActive = true
        headerContainer.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        headerContainer.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        headerContainer.addSubview(separator1)
        separator1.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: 0).isActive = true
        separator1.widthAnchor.constraint(equalTo: headerContainer.widthAnchor).isActive = true
        separator1.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separator1.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor).isActive = true
        // header subviews
        headerContainer.addSubview(userProfilePicture)
        userProfilePicture.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 5).isActive = true
        userProfilePicture.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor).isActive = true
        userProfilePicture.heightAnchor.constraint(equalToConstant: PROFILE_PIC_HEIGHT).isActive = true
        userProfilePicture.widthAnchor.constraint(equalToConstant: PROFILE_PIC_HEIGHT).isActive = true
        
        headerContainer.addSubview(usernameField)
        usernameField.leadingAnchor.constraint(equalTo: userProfilePicture.trailingAnchor, constant: 10).isActive = true
        usernameField.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -2).isActive = true
        usernameField.heightAnchor.constraint(equalTo: headerContainer.heightAnchor, constant: -4).isActive = true
        usernameField.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor).isActive = true
        headerContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(headerTapped)))
        
        self.addSubview(pictureView)
        pictureView.topAnchor.constraint(equalTo: headerContainer.bottomAnchor).isActive = true
        pictureView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        pictureView.heightAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        pictureView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(pictureViewDoubleTapped))
        doubleTap.numberOfTapsRequired = 2
        pictureView.addGestureRecognizer(doubleTap)
        
        pictureView.addSubview(likeView)
        likeView.centerXAnchor.constraint(equalTo: pictureView.centerXAnchor).isActive = true
        likeView.centerYAnchor.constraint(equalTo: pictureView.centerYAnchor).isActive = true
        likeView.widthAnchor.constraint(equalTo: pictureView.widthAnchor, multiplier: 1/3).isActive = true
        likeView.heightAnchor.constraint(equalTo: pictureView.heightAnchor, multiplier: 1/3).isActive = true
        
        self.addSubview(footerContainer)
        footerContainer.topAnchor.constraint(equalTo: self.pictureView.bottomAnchor).isActive = true
        footerContainer.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        footerContainer.heightAnchor.constraint(equalToConstant: 160).isActive = true
        footerContainer.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        //        footerContainer.addSubview(likeContainer)
        //        likeContainer.topAnchor.constraint(equalTo: footerContainer.topAnchor, constant: 5).isActive = true
        //        likeContainer.widthAnchor.constraint(equalTo: footerContainer.widthAnchor, constant: -10).isActive = true
        //        likeContainer.heightAnchor.constraint(equalToConstant: 15).isActive = true
        //        likeContainer.centerXAnchor.constraint(equalTo: footerContainer.centerXAnchor).isActive = true
        //
        //        likeContainer.addSubview(likeImage)
        //        likeImage.leftAnchor.constraint(equalTo: likeContainer.leftAnchor).isActive = true
        //        likeImage.topAnchor.constraint(equalTo: likeContainer.topAnchor).isActive = true
        //        likeImage.widthAnchor.constraint(equalTo: likeContainer.heightAnchor).isActive = true
        //        likeImage.heightAnchor.constraint(equalTo: likeContainer.heightAnchor).isActive = true
        //
        //        setupLikeImage()
        //
        //        likeContainer.addSubview(numberOfLikes)
        //        numberOfLikes.leftAnchor.constraint(equalTo: likeImage.rightAnchor, constant: 5).isActive = true
        //        numberOfLikes.rightAnchor.constraint(equalTo: likeContainer.rightAnchor).isActive = true
        //        numberOfLikes.heightAnchor.constraint(equalTo: likeContainer.heightAnchor).isActive = true
        //        numberOfLikes.topAnchor.constraint(equalTo: likeContainer.topAnchor).isActive = true
        //
        footerContainer.addSubview(captionField)
        captionField.topAnchor.constraint(equalTo: self.pictureView.bottomAnchor, constant: 10).isActive = true
        captionField.widthAnchor.constraint(equalTo: footerContainer.widthAnchor).isActive = true
        captionField.centerXAnchor.constraint(equalTo: footerContainer.centerXAnchor).isActive = true
        captionField.heightAnchor.constraint(equalToConstant: 130).isActive = true
        
        footerContainer.addSubview(locationField)
        locationField.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        locationField.topAnchor.constraint(equalTo: captionField.bottomAnchor).isActive = true
        locationField.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        locationField.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
    }
    
    // This sets the small like icon red if you have liked this post, if not default black is displayed
    func setupLikeImage() {
        
    }
    
    func headerTapped() {
        if self.delegate != nil, let writerId = self.post?.writerId{
            delegate.didSelectProfile(uid: writerId)
        }
    }
    
    func pictureViewDoubleTapped() {
        
        self.animateLike()
        if let delegate = self.delegate, let post = self.post, let postId = post.objectId {
            delegate.didLikePost(postId: postId, completionHandler: {
                Types.tryblock({
                    
                }, catchblock: { (exception) in
                    print("Backendless server error: \(exception as! Fault)")
                })
                
                
                
            })
        }
    }
    
    func animateLike() {
        likeView.alpha = 1
        print("comes here")
        UIView.animate(withDuration: 0.5, animations: {
            self.likeView.alpha = 0
        }, completion: nil)
    }
    
    
    
}

// MARK : - ProfileView Profile Picture Section Cell

class ProfilePictureCell: UICollectionViewCell{
    let profileImage: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = UIColor.green
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 30
        view.layer.masksToBounds = true
        view.clipsToBounds = true
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    let intro: UITextView = {
        let view = UITextView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
        
    }()
    
    let today: UILabel = {
        let label = UILabel()
        label.useSFUIFont(withSize: 10, andStyle: "bold")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "TODAY"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        setupViews()
    }
    
    func setupViews() {
        self.addSubview(profileImage)
        
        profileImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        profileImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 60).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        self.addSubview(intro)
        
        intro.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        intro.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 20).isActive = true
        intro.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        intro.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20).isActive = true
        
        self.addSubview(today)
        
        today.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 20).isActive = true
        today.topAnchor.constraint(equalTo: self.topAnchor, constant: 35).isActive = true
        today.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        today.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        
        
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



class PostPictureCell: UICollectionViewCell{
    let imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        return view
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    func setupViews() {
        self.backgroundColor = UIColor.white
        
        self.addSubview(imageView)
        imageView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK : - MapSnapShotCell

class MapSnapShotCell: UICollectionViewCell {
    let nameOfPlace: UILabel = {
        let label = UILabel()
        label.useSFUIFont(withSize: 20, andStyle: "black")
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.masksToBounds = false
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 5
        label.layer.shadowOpacity = 1
        label.layer.shadowOffset = CGSize(width: 0, height: 0)
        return label
    }()
    
    var location: CLLocation?
    
    var snapshotOfPlace: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    func updateNameOfPlaceAndPicture(urlString: String) {
        CLGeocoder().reverseGeocodeLocation(location!, completionHandler: { (placemarks, error) in
            let placemark = placemarks?[0]
            let city = placemark?.addressDictionary?["City"]
            let country = placemark?.addressDictionary?["Country"]
            if let city = city, let country = country {
                self.nameOfPlace.text = " \(city), \(country)"
            } else {
                print("error at location Geocoder")
            }
        })
        
        // update picture
        print(urlString)
        let url = URL(string: urlString)
        self.snapshotOfPlace.sd_setImage(with: url, completed: { (image, error, cachetype, url) in
            
            if error != nil {
                print(error)
            }
        })
        
    }
    func setupViews() {
        self.addSubview(snapshotOfPlace)
        snapshotOfPlace.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        snapshotOfPlace.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        snapshotOfPlace.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        snapshotOfPlace.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        snapshotOfPlace.addSubview(nameOfPlace)
        nameOfPlace.widthAnchor.constraint(equalTo: self.snapshotOfPlace.widthAnchor).isActive = true
        nameOfPlace.heightAnchor.constraint(equalTo: self.snapshotOfPlace.heightAnchor, multiplier: 1/3)
        nameOfPlace.centerXAnchor.constraint(equalTo: self.snapshotOfPlace.centerXAnchor)
        nameOfPlace.topAnchor.constraint(equalTo: self.snapshotOfPlace.topAnchor)
    }
    
    
}

