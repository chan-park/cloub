//
//  Post.swift
//  cloub
//
//  Created by Chan Hee Park on 10/24/16.
//  Copyright © 2016 Chan Hee Park. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import MapKit

class Post: NSObject {
    var objectId: String?
    var largeSizeImageUrl: String?
    var mediumSizeImageUrl: String?
    var smallSizeImageUrl: String?
    var thumbnail: UIImage?
    var profilePicture: UIImage?
    var caption: String?
    var writer: BackendlessUser?
    var writerId: String?
    var username: String?
    var comments: [Comment]?
    var likes: Int = 0
    var peopleWhoLikedIt: [BackendlessUser]?
    var location: GeoPoint?
    var readableLocation: String?
    
    var updated: NSDate?
    var created: NSDate?
    override init() {
        
    }
}
