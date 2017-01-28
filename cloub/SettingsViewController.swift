//
//  SettingsViewController1.swift
//  cloub
//
//  Created by Chan Hee Park on 11/19/16.
//  Copyright © 2016 Chan Hee Park. All rights reserved.
//

import UIKit
import Firebase
import Social
import FBSDKLoginKit
class SettingsViewController: UITableViewController {
    var backendless = Backendless()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(ButtonCell.self, forCellReuseIdentifier: "Button")
        self.navigationItem.title = "Settings"
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 2:
            return 1
        default:
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let section = indexPath.section
        let cell = tableView.dequeueReusableCell(withIdentifier: "Button") as! ButtonCell
        switch section {
        case 0:
            if row == 0 {
                cell.button.setTitle("Change profile picture", for: .normal)
                cell.button.addTarget(self, action: #selector(editProfilePicture), for: .touchUpInside)
                
            } else if row == 1 {
                cell.button.addTarget(self, action: #selector(editUsername), for: .touchUpInside)
                cell.button.setTitle("Change username", for: .normal)
            }
            break
        case 1:
            if row == 0 {
                cell.button.addTarget(self, action: #selector(postOnFacebook), for: .touchUpInside)
                cell.button.setTitle("Post on Facebook", for: .normal)
            } else if row == 1 {
                cell.button.addTarget(self, action: #selector(tweetOnTwitter), for: .touchUpInside)
                cell.button.setTitle("Tweet", for: .normal)
            }
            break
        case 2:
            if row == 0 {
                cell.button.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
                cell.button.setTitle("Log Out", for: .normal)
            }
            break
        default:
            break
        }
        return cell
        
    }
    
    func editProfilePicture() {
        let vc = ProfileEditViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func editUsername() {
        let vc = UsernameEditViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    
    func postOnFacebook() {
        let fbShare:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        fbShare.setInitialText("Check out this new app that allows you to share location-based messages with a picture! \n \nhttps://itunes.apple.com/us/app/plants-vs.-zombies/id350642635?mt=8")
        self.present(fbShare, animated: true, completion: nil)
    }
    

    
    func tweetOnTwitter() {
        let tweet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        tweet.setInitialText("Check out this new app that allows you to share location-based messages with a picture! \n \nhttps://itunes.apple.com/us/app/plants-vs.-zombies/id350642635?mt=8")
        self.present(tweet, animated: true, completion: nil)
    }
    
    func handleLogout() {
        backendless.userService.logout({ (any) in
            FBSDKLoginManager().logOut()
            FBSDKAccessToken.setCurrent(nil)
            let vc = LoginViewController()
            self.present(vc, animated: true, completion: nil)
        }, error: { fault in
            FBSDKLoginManager().logOut()
            FBSDKAccessToken.setCurrent(nil)
            let vc = LoginViewController()
            self.present(vc, animated: true, completion: nil)
            print("error logging out")
        })
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "EDIT PROFILE"
        case 1:
            return "SHARE"
        case 2:
            return ""
        default:
            return nil
        }
    }
    
}


class ButtonCell: UITableViewCell {
    var button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.black, for: .normal)
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        button.titleLabel?.useSFUIFont(withSize: 15, andStyle: "regular")
        return button
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(button)
        button.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        button.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        button.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
