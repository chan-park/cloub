//
//  User.swift
//  cloub
//
//  Created by Chan Hee Park on 10/24/16.
//  Copyright © 2016 Chan Hee Park. All rights reserved.
//

import Foundation
import UIKit

class User {
    var uid: String?
    var values: [String:Any]?
    init(uid: String, values: [String:Any]) {
        self.uid = uid
        self.values = values
    }
}
