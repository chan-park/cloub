//
//  CloubClusterRenderer.swift
//  cloub
//
//  Created by Chan Hee Park on 12/7/16.
//  Copyright © 2016 Chan Hee Park. All rights reserved.
//

import Foundation

class CloubClusterRenderer: GMUDefaultClusterRenderer {
    
    override func shouldRender(as cluster: GMUCluster, atZoom zoom: Float) -> Bool {
        print("zoom:\(zoom)")
        return cluster.count >= 2 && zoom <= 21
    }
}
