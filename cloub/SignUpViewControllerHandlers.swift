//
//  SignUpViewController+handlers.swift
//  cloub
//
//  Created by Chan Hee Park on 10/21/16.
//  Copyright © 2016 Chan Hee Park. All rights reserved.
//

import UIKit
extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func handleUploadProfiePicture() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profilePicture.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
}
