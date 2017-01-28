//
//  UsernameEditViewController.swift
//  cloub
//
//  Created by Chan Hee Park on 11/19/16.
//  Copyright © 2016 Chan Hee Park. All rights reserved.
//

import UIKit
import Firebase
class UsernameEditViewController: UIViewController, UITextFieldDelegate {
    let textField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.title = "Edit Username"
        setupView()
    }
    
    func setupView() {
        self.view.addSubview(textField)
        textField.delegate = self
        textField.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -40).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        textField.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        textField.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        
        let underline: UIView = {
            let underline = UIView()
            underline.translatesAutoresizingMaskIntoConstraints = false
            underline.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
            return underline
        }()
        
        textField.addSubview(underline)
        underline.bottomAnchor.constraint(equalTo: textField.bottomAnchor, constant: -5).isActive = true
        underline.widthAnchor.constraint(equalTo: textField.widthAnchor).isActive = true
        underline.heightAnchor.constraint(equalToConstant: 1).isActive = true
        underline.centerXAnchor.constraint(equalTo: textField.centerXAnchor).isActive = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let input = textField.text! + string
        guard validInput(input: input) else {
            print("Must be more than 5 characters. Must not contain any special characters.\(textField.text)")
            return true
        }
        let text = textField.text! + string
        let usernamesRef = FIRDatabase.database().reference().child("usernames")
        usernamesRef.observeSingleEvent(of: .value, with: {
            snapshot in
            if snapshot.hasChild(text) {
                self.indicateInvalidOrExistingUsername()
            } else {
                self.indicateValidUsername()
            }
        })
        return true
    }
    
    func validInput(input: String?) -> Bool{
        // valid if it doesn't contain any special character and length is at least 5
        if input == nil || (input?.characters.count)! < 5 {
            return false
        }
            
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789")
        if input?.rangeOfCharacter(from: characterset.inverted) != nil {
            return false
        } else {
            return true
        }
    }
    
    func indicateInvalidOrExistingUsername() {
        print("This username already exists.")
    }
    
    func indicateValidUsername() {
        print("This username is valid.")
    }
    
    
}
