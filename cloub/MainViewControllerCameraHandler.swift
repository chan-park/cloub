//
//  MainViewControllerCameraHandler.swift
//  cloub
//
//  Created by Chan Hee Park on 10/26/16.
//  Copyright © 2016 Chan Hee Park. All rights reserved.
//

import UIKit
import MapKit
extension MainViewController {
    func takePicture() {
        let status = CLLocationManager.authorizationStatus()
        guard status == CLAuthorizationStatus.authorizedWhenInUse || status == CLAuthorizationStatus.authorizedAlways else {
            let alertUserForLocation = UIAlertController(title: "Allow Location Service", message: "You need to allow location service to post.", preferredStyle: .actionSheet)
            let goToSettingAction = UIAlertAction(title: "Go To Settings", style: .default, handler: { (action) in
                UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                print("alert:: user denied to use location service!")
            })
            
            alertUserForLocation.addAction(goToSettingAction)
            alertUserForLocation.addAction(cancelAction)
            self.present(alertUserForLocation, animated: true, completion: nil)
            return
        }
        

        let vc = AddPostViewController()
        //vc.location = self.userLocation
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
