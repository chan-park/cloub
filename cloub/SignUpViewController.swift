//
//  SignUpViewController.swift
//  cloub
//
//  Created by Chan Hee Park on 10/20/16.
//  Copyright © 2016 Chan Hee Park. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
class SignUpViewController: UIViewController {
    var blurredView: UIVisualEffectView = UIVisualEffectView()
    var backendless = Backendless()
    lazy var profilePicture: UIImageView = {
        let picView = UIImageView()
        picView.translatesAutoresizingMaskIntoConstraints = false
        picView.contentMode = .scaleAspectFill
        picView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadProfiePicture)))
        picView.isUserInteractionEnabled = true
        picView.layer.cornerRadius = 50
        picView.layer.masksToBounds = true
        picView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        return picView
    }()
    
    let usernameContainerView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor.blue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let usernameField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
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
    
    let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.useSFUIFont(withSize: 15, andStyle: "bold")
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitle("CREATE", for: .normal)
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red:0.89, green:0.00, blue:0.40, alpha:1.0)
        return button
    }()
    
    let closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named:"Delete.png"), for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // keyboard dismiss
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        // setup blur view
        self.view.backgroundColor = UIColor.clear
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        self.blurredView = UIVisualEffectView(effect: blurEffect)
        blurredView.frame = self.view.bounds
        self.view.addSubview(blurredView)
        
        // setup other views
        setupInputContainerView()
        setupProfilePicture()
        setupUsernameContainerView()
        setupEmailContainerView()
        setupPasswordContainerView()
        setupCreateButton()
        setupCloseButton()
        
        
    }
    
    
    
    func setupCloseButton() {
        self.blurredView.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        closeButton.rightAnchor.constraint(equalTo: self.blurredView.rightAnchor, constant: -20).isActive = true
        closeButton.topAnchor.constraint(equalTo: self.blurredView.topAnchor, constant: 20).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
    }
    func handleClose() {
        dismiss(animated: true, completion: nil)
    }
    func setupProfilePicture() {
        self.blurredView.addSubview(profilePicture)
        // Constraints
        profilePicture.centerXAnchor.constraint(equalTo: self.blurredView.centerXAnchor).isActive = true
        profilePicture.bottomAnchor.constraint(equalTo: self.inputContainerView.topAnchor, constant: -30).isActive = true
        profilePicture.widthAnchor.constraint(equalToConstant: 100).isActive = true
        profilePicture.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    func setupInputContainerView() {
        self.blurredView.addSubview(inputContainerView)
        inputContainerView.centerXAnchor.constraint(equalTo: self.blurredView.centerXAnchor).isActive = true
        inputContainerView.heightAnchor.constraint(equalTo: self.blurredView.heightAnchor, multiplier: 1/3).isActive = true
        inputContainerView.widthAnchor.constraint(equalTo: self.blurredView.widthAnchor).isActive = true
        inputContainerView.centerYAnchor.constraint(equalTo: self.blurredView.centerYAnchor).isActive = true
    }
    
    func setupUsernameContainerView() {
        self.inputContainerView.addSubview(usernameContainerView)
        
        self.usernameContainerView.centerXAnchor.constraint(equalTo: self.inputContainerView.centerXAnchor).isActive = true
        self.usernameContainerView.topAnchor.constraint(equalTo: inputContainerView.topAnchor).isActive = true
        self.usernameContainerView.widthAnchor.constraint(equalTo: self.inputContainerView.widthAnchor, multiplier: 2/3).isActive = true
        self.usernameContainerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        // username label
        let usernameLabel: UILabel = {
            let label = UILabel()
            label.text = "USERNAME:"
            label.textColor = UIColor.white
            label.translatesAutoresizingMaskIntoConstraints = false
            label.useSFUIFont(withSize: 10, andStyle: "bold")
            return label
        }()
        usernameContainerView.addSubview(usernameLabel)
        usernameLabel.leftAnchor.constraint(equalTo: usernameContainerView.leftAnchor).isActive = true
        usernameLabel.topAnchor.constraint(equalTo: usernameContainerView.topAnchor).isActive = true
        usernameLabel.widthAnchor.constraint(equalTo: usernameContainerView.widthAnchor).isActive = true
        usernameLabel.heightAnchor.constraint(equalTo: usernameContainerView.heightAnchor, multiplier: 1/2).isActive = true
        
        usernameContainerView.addSubview(usernameField)
        usernameField.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor).isActive = true
        usernameField.leftAnchor.constraint(equalTo: usernameContainerView.leftAnchor).isActive = true
        usernameField.widthAnchor.constraint(equalTo: usernameContainerView.widthAnchor).isActive = true
        usernameField.heightAnchor.constraint(equalTo: usernameContainerView.heightAnchor, multiplier: 1/2).isActive = true
        
        let underline: UIView = {
            let underline = UIView()
            underline.translatesAutoresizingMaskIntoConstraints = false
            underline.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
            return underline
        }()
        
        usernameField.addSubview(underline)
        underline.centerXAnchor.constraint(equalTo: usernameField.centerXAnchor).isActive = true
        underline.bottomAnchor.constraint(equalTo: usernameField.bottomAnchor, constant: 0).isActive = true
        underline.widthAnchor.constraint(equalTo: usernameField.widthAnchor).isActive = true
        underline.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    func setupEmailContainerView() {
        self.inputContainerView.addSubview(emailContainerView)
        
        self.emailContainerView.centerXAnchor.constraint(equalTo: inputContainerView.centerXAnchor).isActive = true
        self.emailContainerView.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor).isActive = true
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
            underline.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
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
            underline.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
            return underline
        }()
        
        passwordField.addSubview(underline)
        underline.centerXAnchor.constraint(equalTo: passwordField.centerXAnchor).isActive = true
        underline.bottomAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 0).isActive = true
        underline.widthAnchor.constraint(equalTo: passwordField.widthAnchor).isActive = true
        underline.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
    }
    
    func setupCreateButton() {
        self.blurredView.addSubview(createButton)
        self.createButton.addTarget(self, action: #selector(handleCreateUser), for: .touchUpInside)
        
        
        // Constraints
        createButton.widthAnchor.constraint(equalTo: self.blurredView.widthAnchor, multiplier: 1/2).isActive = true
        createButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        createButton.topAnchor.constraint(equalTo: self.inputContainerView.bottomAnchor, constant: 50).isActive = true
        createButton.centerXAnchor.constraint(equalTo: self.blurredView.centerXAnchor).isActive = true
    }
    
    
    
    
    func handleCreateUser() {
        
        guard let username = usernameField.text, let email = emailField.text, let password = passwordField.text else {
            print("Form is not valid.")
            return
        }
        
        let user = BackendlessUser()
        let imageName = UUID().uuidString
        user.setProperty("username", object: username)
        user.setProperty("email", object: email)
        user.setProperty("password", object: password)
        
        if let profileImage = self.profilePicture.image {
            let resizedImage = Util.resizeImage(image: profileImage, targetSize: CGSize(width: GlobalConstants.SMALL_SIZE_IMAGE_WIDTH, height: GlobalConstants.SMALL_SIZE_IMAGE_WIDTH))
            backendless.fileService.upload("/pictures/profile/\(imageName)", content: UIImagePNGRepresentation(resizedImage), response: { (file) in
                if let file = file {
                    // save profile picture url to database
                    user.setProperty("profile_picture_url", object: file.fileURL)
                    
                    // save to database
                    self.saveToDatabase(user: user)
                    
                }
            }, error: { (fault) in
                if let fault = fault {
                    print("profile picture upload error: \(fault.detail)")
                    self.saveToDatabase(user: user)
                }
            })
        }
    }
    
    private func saveToDatabase(user: BackendlessUser) {
        self.backendless.userService.registering(user, response: { result_user in
            self.dismiss(animated: true, completion: nil)
        }, error: {fault in
            if let fault = fault {
                print("register error:: \(fault.faultCode)")
            }
        })
    }
    
    
    func dismissKeyboard() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        usernameField.resignFirstResponder()
    }
}
