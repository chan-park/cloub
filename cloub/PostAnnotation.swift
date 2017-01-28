//
//  PinAnnotationView.swift
//  cloub
//
//  Created by Chan Hee Park on 12/4/16.
//  Copyright © 2016 Chan Hee Park. All rights reserved.
//

import Foundation
import MapKit

class PostAnnotation: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var post: Post?
    init(position: CLLocationCoordinate2D, post: Post) {
        self.position = position
        self.post = post
    }
    
}
