//
//  LoginViewController.swift
//  cloub
//
//  Created by Chan Hee Park on 10/19/16.
//  Copyright © 2016 Chan Hee Park. All rights reserved.
//


import UIKit
import Firebase
import FBSDKLoginKit
import FBSDKCoreKit

protocol LoginDelegate {
    func didLogIn() -> Void
}
class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    var delegate: LoginDelegate?
    
    var backendless = Backendless.sharedInstance()
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("LOG IN", for: .normal)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.backgroundColor = UIColor(red:1.00, green:0.42, blue:0.42, alpha:1.0)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.useSFUIFont(withSize: 15, andStyle: "bold")
        return button
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("SIGN UP", for: .normal)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.backgroundColor = UIColor(red:1.00, green:0.42, blue:0.42, alpha:1.0)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.useSFUIFont(withSize: 15, andStyle: "bold")
        return button
    }()
    
    let facebookLoginButton: FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.readPermissions = ["email", "public_profile"]
        
        return button
    }()
    
    let emailContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let emailField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let passwordContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let passwordField: UITextField = {
        let tf = UITextField()
        tf.isSecureTextEntry = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let inputContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "cloub"
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.useSFUIFont(withSize: 80, andStyle: "black")
        return label
    }()
    
    let emptySpace: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // keyboard dismiss
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        //self.view.backgroundColor = UIColor(red:0.97, green:1.00, blue:0.97, alpha:1.0) // mint
        // self.view.backgroundColor = UIColor(red:0.25, green:0.34, blue:0.96, alpha:1.0)
        self.view.backgroundColor = UIColor(red:0.18, green:0.75, blue:0.98, alpha:1.0)
        setupInputContainerView()
        setupTitleLabel()
        setupEmailContainerView()
        setupPasswordContainerView()
        setupLoginButton()
        setupSignUpButton()
        setupFBLoginButton()
        
        
    }
    // MARK: - TitleLabel
    
    func setupTitleLabel() {
        self.view.addSubview(self.emptySpace)
        emptySpace.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        emptySpace.bottomAnchor.constraint(equalTo: self.inputContainerView.topAnchor).isActive = true
        emptySpace.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        emptySpace.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        self.emptySpace.addSubview(self.titleLabel)
        titleLabel.centerXAnchor.constraint(equalTo: self.emptySpace.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: self.emptySpace.centerYAnchor).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: self.emptySpace.widthAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    
    // MARK: - UI
    
    
    func setupLoginButton() {
        self.view.addSubview(loginButton)
        loginButton.addTarget(self, action: #selector(loginViaEmail), for: .touchUpInside)
        loginButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1/2).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        loginButton.topAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: 30).isActive = true
    }
    
    func setupSignUpButton() {
        self.view.addSubview(signUpButton)
        signUpButton.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        signUpButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1/2).isActive = true
        signUpButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        signUpButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        signUpButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 10).isActive = true
    }
    
    func setupFBLoginButton() {
        self.view.addSubview(facebookLoginButton)
        facebookLoginButton.delegate = self
        facebookLoginButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1/2).isActive = true
        facebookLoginButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        facebookLoginButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        facebookLoginButton.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 10).isActive = true
        
        
    }
    
    
    
    
    func setupInputContainerView() {
        self.view.addSubview(inputContainerView)
        inputContainerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        inputContainerView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        inputContainerView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1/5).isActive = true
        inputContainerView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        
    }
    
    
    func setupEmailContainerView() {
        self.inputContainerView.addSubview(emailContainerView)
        
        self.emailContainerView.centerXAnchor.constraint(equalTo: inputContainerView.centerXAnchor).isActive = true
        self.emailContainerView.topAnchor.constraint(equalTo: inputContainerView.topAnchor).isActive = true
        self.emailContainerView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor, multiplier: 2/3).isActive = true
        self.emailContainerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        // email label
        let emailLabel: UILabel = {
            let label = UILabel()
            label.text = "EMAIL:"
            label.textColor = UIColor.white
            label.translatesAutoresizingMaskIntoConstraints = false
            label.useSFUIFont(withSize: 10, andStyle: "bold")
            return label
        }()
        emailContainerView.addSubview(emailLabel)
        emailLabel.leftAnchor.constraint(equalTo: emailContainerView.leftAnchor).isActive = true
        emailLabel.topAnchor.constraint(equalTo: emailContainerView.topAnchor).isActive = true
        emailLabel.widthAnchor.constraint(equalTo: emailContainerView.widthAnchor).isActive = true
        emailLabel.heightAnchor.constraint(equalTo: emailContainerView.heightAnchor, multiplier: 1/2).isActive = true
        
        emailContainerView.addSubview(emailField)
        emailField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor).isActive = true
        emailField.leftAnchor.constraint(equalTo: emailContainerView.leftAnchor).isActive = true
        emailField.widthAnchor.constraint(equalTo: emailContainerView.widthAnchor).isActive = true
        emailField.heightAnchor.constraint(equalTo: emailContainerView.heightAnchor, multiplier: 1/2).isActive = true
        
        let underline: UIView = {
            let underline = UIView()
            underline.translatesAutoresizingMaskIntoConstraints = false
            underline.backgroundColor = UIColor.white
            return underline
        }()
        
        emailField.addSubview(underline)
        underline.centerXAnchor.constraint(equalTo: emailField.centerXAnchor).isActive = true
        underline.bottomAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 0).isActive = true
        underline.widthAnchor.constraint(equalTo: emailField.widthAnchor).isActive = true
        underline.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
    }
    
    func setupPasswordContainerView() {
        self.inputContainerView.addSubview(passwordContainerView)
        
        self.passwordContainerView.centerXAnchor.constraint(equalTo: inputContainerView.centerXAnchor).isActive = true
        self.passwordContainerView.bottomAnchor.constraint(equalTo: inputContainerView.bottomAnchor).isActive = true
        self.passwordContainerView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor, multiplier: 2/3).isActive = true
        self.passwordContainerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        // password label
        let passwordLabel: UILabel = {
            let label = UILabel()
            label.text = "PASSWORD:"
            label.textColor = UIColor.white
            label.translatesAutoresizingMaskIntoConstraints = false
            label.useSFUIFont(withSize: 10, andStyle: "bold")
            return label
        }()
        passwordContainerView.addSubview(passwordLabel)
        passwordLabel.leftAnchor.constraint(equalTo: passwordContainerView.leftAnchor).isActive = true
        passwordLabel.topAnchor.constraint(equalTo: passwordContainerView.topAnchor).isActive = true
        passwordLabel.widthAnchor.constraint(equalTo: passwordContainerView.widthAnchor).isActive = true
        passwordLabel.heightAnchor.constraint(equalTo: passwordContainerView.heightAnchor, multiplier: 1/2).isActive = true
        
        passwordContainerView.addSubview(passwordField)
        passwordField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor).isActive = true
        passwordField.leftAnchor.constraint(equalTo: passwordContainerView.leftAnchor).isActive = true
        passwordField.widthAnchor.constraint(equalTo: passwordContainerView.widthAnchor).isActive = true
        passwordField.heightAnchor.constraint(equalTo: passwordContainerView.heightAnchor, multiplier: 1/2).isActive = true
        
        let underline: UIView = {
            let underline = UIView()
            underline.translatesAutoresizingMaskIntoConstraints = false
            underline.backgroundColor = UIColor.white
            return underline
        }()
        
        passwordField.addSubview(underline)
        underline.centerXAnchor.constraint(equalTo: passwordField.centerXAnchor).isActive = true
        underline.bottomAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 0).isActive = true
        underline.widthAnchor.constraint(equalTo: passwordField.widthAnchor).isActive = true
        underline.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
    }
    
    
    // MARK: - Login Functions
    
    
    // Called when user logged in with emai
    func loginViaEmail() {
        backendless?.userService.login(self.emailField.text!, password: self.passwordField.text!, response: { (user) in
            print("login successful!")
            let loggedUser = user! as BackendlessUser
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "USER_LOGGED_IN"), object: nil, userInfo: ["loggedUser": loggedUser])
            
            self.dismiss(animated: true, completion: nil)
        }, error: { (fault) in
            let alertView = UIAlertController(title: "Login Fail", message: "Username or password incorrect", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: {
                action in
                
            })
            alertView.addAction(alertAction)
            self.present(alertView, animated: true, completion: nil)
            return
        })
    }
    
    
    // facebook login delegate protocols
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if error != nil {
            print(error.localizedDescription)
            return
            
        }
        if let token = FBSDKAccessToken.current() {
            let fieldsMapping = [
                "id" : "facebookId",
                "name" : "name",
                "birthday": "birthday",
                "first_name": "fb_first_name",
                "last_name" : "fb_last_name",
                "gender": "gender",
                "email": "email"
            ]
            
            Types.tryblock({
                let query = BackendlessDataQuery()
                query.whereClause = "facebookId = '\(token.userID!)'"
                
                if let bc = self.backendless?.data.of(BackendlessUser.ofClass()).find(query) {
                    if bc.data.count > 0 {
                        // user exists, no need to perform FBGraphRequest
                        self.backendless?.userService.login(withFacebookSDK: token, fieldsMapping: fieldsMapping, response: { (user) in
                            //print("\(user?.getProperty("username")!) successfully logged in")
                            
                            let loggedUser = user! as BackendlessUser
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "USER_LOGGED_IN"), object: nil, userInfo: ["loggedUser": loggedUser])
                            
                            self.dismiss(animated: true, completion: nil)
                        }, error: { (fault) in
                            if let fault = fault {
                                print(fault.message)
                            }
                        })
                    } else {
                        self.mapFacebookDataToBackendlessData(token: token)
                    }
                }
            }, catchblock: { (exception) in
                print("Server reported an error: \(exception as! Fault)")
            })
        }
    }
    
    
    // This mapping from facebook to backendless happens if is logging with facebook account the first time.
    func mapFacebookDataToBackendlessData(token: FBSDKAccessToken) {
        let fieldsMapping = [
            "id" : "facebookId",
            "name" : "name",
            "birthday": "birthday",
            "first_name": "fb_first_name",
            "last_name" : "fb_last_name",
            "gender": "gender",
            "email": "email"
        ]
        let parameters = ["fields": "email, first_name,last_name,picture.type(large)"]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start(completionHandler: { (connection, result, error) in
            if let error = error {
                print(error)
                return
            }
            
            self.backendless?.userService.login(withFacebookSDK: token, fieldsMapping: fieldsMapping, response: { (user) in
                
                Types.tryblock({
                    print("fetch\(user?.getProperty("profile_picture_url"))")
                    let result = result as! [String: Any]
                    if let email = result["email"] as? String, let user = user {
                        user.setProperty("email", object: email)
                    }
                    
                    if let user = user {
                        self.fetchAvailableRandomUsername(completion: { (username) in
                            if let username = username {
                                user.setProperty("username", object: username)
                            } else {
                                // worst case
                                user.setProperty("username", object: Util.generateRandomStringWithLength(len: 8))
                            }
                        })
                    }
                    
                    
                    if let picture = result["picture"] as? [String: Any], let data = picture["data"] as? [String: Any], let url = data["url"] as? String, let user = user {
                        user.setProperty("profile_picture_url", object: url)
                    }
                    
                    if let uid = token.userID, let user = user {
                        user.setProperty("uid", object: uid)
                    }
                    
                    self.backendless?.userService.update(user, response: { (user) in
                        print("saved to database successfully")
                        let loggedUser = user! as BackendlessUser
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "USER_LOGGED_IN"), object: nil, userInfo: ["loggedUser": loggedUser])
                    }, error: { (fault) in
                        if let fault = fault {
                            print(fault.message)
                        }
                    })
                }, catchblock: { (exception) in
                    print("Server reported an error: \(exception as! Fault)")
                })
                
                
                self.dismiss(animated: true, completion: nil)
            }, error: { (fault) in
                if let fault = fault {
                    print(fault.detail)
                }
            })
        })
        
    }
    
    func fetchAvailableRandomUsername(completion: @escaping (String?)->()) {
        Types.tryblock({
            var found = false
            while found == false {
                let randomId = Util.generateRandomStringWithLength(len: 8)
                let query = BackendlessDataQuery()
                query.whereClause = "username = '\(randomId)'"
                if let usernames = self.backendless?.data.of(BackendlessUser.ofClass()).find(query) {
                    if usernames.data.count == 0 {
                        completion(randomId)
                        found = true
                    }
                } else {
                    completion(nil)
                }
            }
        }, catchblock: { (exception) -> Void in
            print("Server reported an error: \(exception as! Fault)")
        })
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        // add code
        print("Logged out successfully")
        return
    }
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        // add code
        return true
    }
    
    func handleSignUp() {
        let signUpVC = SignUpViewController()
        signUpVC.modalPresentationStyle = .overFullScreen
        self.present(signUpVC, animated: true, completion: nil)
        
    }
    
    func dismissKeyboard() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
    
}

