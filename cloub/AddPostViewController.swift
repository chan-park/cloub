//
//  ViewController.swift
//  CustomCamera
//
//  Created by Chan Hee Park on 11/12/16.
//  Copyright © 2016 Chan Hee Park. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import MapKit

import AVFoundation
class AddPostViewController: UIViewController, UITextViewDelegate, AVCapturePhotoCaptureDelegate, CLLocationManagerDelegate {
    var backendless = Backendless()
    var AVOutput: AVCapturePhotoOutput?
    var onEdit = false
    var location: CLLocation?
    var locationManager: CLLocationManager = CLLocationManager()
    var noCamera = false
    let previewView: UIView = {
        let view =  UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))
        view.isUserInteractionEnabled = true
        return view
    }()
    
    let blurView: UIVisualEffectView = {
        let view = UIVisualEffectView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.effect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        return view
    }()
    
    let textView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.font = UIFont(name: "SFUIDisplay-Black", size: 30)
        view.textColor = UIColor.white
        
        return view
    }()
    
    let placeHolderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.useSFUIFont(withSize: 30, andStyle: "bold")
        label.text = "What's Up?"
        label.isHidden = false
        label.textColor = UIColor.white
        return label
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let cameraSwitchButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: UIScreen.main.bounds.width - 50, y: UIScreen.main.bounds.width - 50, width: 50, height: 50)
        button.backgroundColor = UIColor.clear
        button.setImage(UIImage(named: "CameraSwitch.png"), for: .normal)
        button.tintColor = UIColor.white
        return button
    }()
    
    var session = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var captureDeviceBack: AVCaptureDevice?
    var captureDeviceFront: AVCaptureDevice?
    var currentCaptureDevice: AVCaptureDevice?
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(share_backendless1))
        self.view.backgroundColor = UIColor.white
        self.tabBarController?.tabBar.isHidden = true
        self.imageView.isHidden = true
        self.locationManager.delegate = self
        self.locationManager.requestLocation()
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardShown), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        setupViews()
        
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("LOCATION UPDATE")
        self.location = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func setupViews() {
        
        self.view.addSubview(previewView)
        previewView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressTakePhoto)))
        self.previewView.addSubview(self.cameraSwitchButton)
        
        self.cameraSwitchButton.addTarget(self, action: #selector(switchCamera), for: .touchUpInside)
        
        
        self.view.addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        self.view.addSubview(blurView)
        
        blurView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: UIScreen.main.bounds.width).isActive = true
        blurView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height).isActive = true
        blurView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        blurView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        textView.delegate = self
        blurView.addSubview(textView)
        textView.topAnchor.constraint(equalTo: self.blurView.topAnchor).isActive = true
        textView.widthAnchor.constraint(equalTo: self.blurView.widthAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        textView.centerXAnchor.constraint(equalTo: self.blurView.centerXAnchor).isActive = true
        
        textView.addSubview(placeHolderLabel)
        placeHolderLabel.topAnchor.constraint(equalTo: self.textView.topAnchor, constant: 6).isActive = true
        placeHolderLabel.leftAnchor.constraint(equalTo: self.textView.leftAnchor, constant: 4).isActive = true
        placeHolderLabel.widthAnchor.constraint(equalTo: self.textView.widthAnchor).isActive = true
        placeHolderLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    
    
    
    
    // this establishes a relation geo -> post -> user
    func share_backendless1() {
        if noCamera {
            imageView.isHidden = false
            imageView.image = UIImage(named: "example.png")
        }
        
        guard self.imageView.isHidden == false, let location = self.location else {
            print("error:: need picture to upload")
            return
        }
        
        if let user = backendless.userService.currentUser {
            
            let largeSizeImageName = UUID().uuidString
            let mediumSizeImageName = UUID().uuidString
            let smallSizeImageName = UUID().uuidString
            
            let point = GEO_POINT(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            
            Types.tryblock({
                let post = Post()
                post.writer = user
                post.writerId = user.objectId as String?
                post.likes = 0
                post.caption = self.textView.text
                
                
                let largeSizeImage = self.imageView.image?.imageByScalingAndCropping(for: CGSize(width: GlobalConstants.ORIGINAL_SIZE_IMAGE_WDITH, height: GlobalConstants.ORIGINAL_SIZE_IMAGE_WDITH))
                let mediumSizeImage = Util.resizeImage(image: self.imageView.image!, targetSize: CGSize(width: GlobalConstants.MEDIUM_SIZE_IMAGE_WIDTH, height: GlobalConstants.MEDIUM_SIZE_IMAGE_WIDTH))
                let smallSizeImage = Util.resizeImage(image: self.imageView.image!, targetSize: CGSize(width: GlobalConstants.SMALL_SIZE_IMAGE_WIDTH, height: GlobalConstants.SMALL_SIZE_IMAGE_WIDTH))
                
                if let file = self.backendless.fileService.upload("/pictures/\(user.objectId!)/largeSizePictures/\(largeSizeImageName)", content: UIImagePNGRepresentation(largeSizeImage!)) {
                    post.largeSizeImageUrl = file.fileURL
                }
                if let file = self.backendless.fileService.upload("/pictures/\(user.objectId!)/mediumSizePictures/\(mediumSizeImageName)", content: UIImagePNGRepresentation(mediumSizeImage)) {
                    post.mediumSizeImageUrl = file.fileURL
                }
                if let file = self.backendless.fileService.upload("/pictures/\(user.objectId!)/smallSizeoPictures/\(smallSizeImageName)", content: UIImagePNGRepresentation(smallSizeImage)) {
                    post.smallSizeImageUrl = file.fileURL
                }
                
                
                let point = GeoPoint.geoPoint(point, categories: ["post"], metadata: ["Post": post]) as? GeoPoint
                
                self.backendless.geoService.save(point, response: { (point) in
                    print("\(point) saved.")
                    
                    
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue:"NEW_POST_ADDED"), object: nil, userInfo: ["newPost": post])
                    
                    self.navigationController?.popViewController(animated: true)
                }, error: { (fault) in
                    if let fault = fault {
                        print(fault.message)
                    }
                })
                
                
                
                
            }, catchblock: { exception in
                print("Backendless error: \(exception as! Fault)")
            })
            
            
        }
        
        
    }
    
    
    
    // this establishes a relation user -> post -> geo order
    func share_backendless2() {
        
        guard self.imageView.isHidden == false, let location = self.location else {
            print("error:: need picture to upload")
            return
        }
        
        if let user = backendless.userService.currentUser {
            
            let largeSizeImageName = UUID().uuidString
            let mediumSizeImageName = UUID().uuidString
            let smallSizeImageName = UUID().uuidString
            
            let point = GEO_POINT(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            
            Types.tryblock({
                let post = Post()
                
                post.writerId = user.objectId as String?
                post.likes = 0
                post.caption = self.textView.text
                post.location = GeoPoint.geoPoint(point, categories: ["post"], metadata: [:]) as? GeoPoint
                
                
                let largeSizeImage = self.imageView.image?.imageByScalingAndCropping(for: CGSize(width: GlobalConstants.ORIGINAL_SIZE_IMAGE_WDITH, height: GlobalConstants.ORIGINAL_SIZE_IMAGE_WDITH))
                let mediumSizeImage = Util.resizeImage(image: self.imageView.image!, targetSize: CGSize(width: GlobalConstants.MEDIUM_SIZE_IMAGE_WIDTH, height: GlobalConstants.MEDIUM_SIZE_IMAGE_WIDTH))
                let smallSizeImage = Util.resizeImage(image: self.imageView.image!, targetSize: CGSize(width: GlobalConstants.SMALL_SIZE_IMAGE_WIDTH, height: GlobalConstants.SMALL_SIZE_IMAGE_WIDTH))
                
                if let file = self.backendless.fileService.upload("/pictures/\(user.objectId!)/largeSizePictures/\(largeSizeImageName)", content: UIImagePNGRepresentation(largeSizeImage!)) {
                    post.largeSizeImageUrl = file.fileURL
                }
                if let file = self.backendless.fileService.upload("/pictures/\(user.objectId!)/mediumSizePictures/\(mediumSizeImageName)", content: UIImagePNGRepresentation(mediumSizeImage)) {
                    post.mediumSizeImageUrl = file.fileURL
                }
                if let file = self.backendless.fileService.upload("/pictures/\(user.objectId!)/smallSizeoPictures/\(smallSizeImageName)", content: UIImagePNGRepresentation(smallSizeImage)) {
                    post.smallSizeImageUrl = file.fileURL
                }
                
                
                
                
                
                
                if var posts = user.getProperty("posts") as? [Post] {
                    posts.append(post)
                    user.setProperty("posts", object: posts)
                    self.backendless.data.of(BackendlessUser.ofClass()).save(user, response: { (result) in
                        self.navigationController?.popViewController(animated: true)
                    }, error: {fault in
                        if let fault = fault {
                            print(fault.message)
                        }
                    })
                }
                
                
            }, catchblock: { exception in
                print("Backendless error: \(exception as! Fault)")
            })
            
            
        }
        
        
    }
    
    
    
    
    func keyboardShown(notification: NSNotification) {
        onEdit = true
        let info  = notification.userInfo!
        let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]! as AnyObject
        let rawFrame = value.cgRectValue
        let keyboardFrame = view.convert(rawFrame!, from: nil)
        animateTextView(true, amount: keyboardFrame.height)
        
    }
    
    func keyboardHide(notification: NSNotification) {
        onEdit = false
        let info  = notification.userInfo!
        let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]! as AnyObject
        let rawFrame = value.cgRectValue
        let keyboardFrame = view.convert(rawFrame!, from: nil)
        animateTextView(false, amount: keyboardFrame.height)
    }
    
    func animateTextView(_ up: Bool, amount: CGFloat) {
        let movementDistance = amount
        let movementDuration: Float = 0.3
        let movement = (up ? -movementDistance : movementDistance)
        UIView.beginAnimations("anim", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(TimeInterval(movementDuration))
        self.blurView.frame = self.blurView.frame.offsetBy(dx: 0, dy: CGFloat(movement))
        UIView.commitAnimations()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            placeHolderLabel.isHidden = true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            placeHolderLabel.isHidden = false
        }
    }
    
    // set max character
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentCharacterCount = textView.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + text.characters.count - range.length
        return newLength <= 100
    }
    
    
    // MARK : - Setup Custom Camera
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        
        beginSession()
        
    }
    
    func defaultDevice(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        
        if let device = AVCaptureDevice.defaultDevice(withDeviceType: AVCaptureDeviceType.builtInDuoCamera,
                                                      mediaType: AVMediaTypeVideo,
                                                      position: position) {
            return device
        } else if let device = AVCaptureDevice.defaultDevice(withDeviceType: AVCaptureDeviceType.builtInWideAngleCamera,
                                                             mediaType: AVMediaTypeVideo,
                                                             position: position) {
            return device
        } else {
            return nil
        }
    }
    
    func beginSession() {
        self.currentCaptureDevice = self.captureDeviceBack
        
        
        do {
            if let availableDefaultDevice = self.defaultDevice(position: AVCaptureDevicePosition.back) {
                self.currentCaptureDevice = availableDefaultDevice
                try session.addInput(AVCaptureDeviceInput(device: availableDefaultDevice))
            } else {
                print("No capture device available!")
                self.noCamera = true // for debugging with laptop
                return
            }
        } catch {
            print("error:: addInput")
            return
        }
        
        AVOutput = AVCapturePhotoOutput()
        if session.canAddOutput(AVOutput) == true {
            session.addOutput(AVOutput)
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            //self.previewView.layer.addSublayer(previewLayer!)
            self.previewView.layer.insertSublayer(previewLayer!, below: self.cameraSwitchButton.layer)
            previewLayer?.connection.videoOrientation = .portrait
            previewLayer?.frame = self.previewView.layer.frame
            session.startRunning()
        }
    }
    
    func switchCamera() {
        guard session.inputs != nil else {
            print("session is empty")
            return
        }
        print("Current session: \(self.session.inputs)")
        session.stopRunning()
        if self.currentCaptureDevice?.position == AVCaptureDevicePosition.back {
            session.removeInput(session.inputs.first as! AVCaptureInput!)
            
            if let availableFrontDevice = self.defaultDevice(position: AVCaptureDevicePosition.front) {
                self.currentCaptureDevice = availableFrontDevice
                do {
                    try session.addInput(AVCaptureDeviceInput(device: availableFrontDevice))
                } catch {
                    print("No front camera")
                    return
                }
                
            }
        } else if self.currentCaptureDevice?.position == AVCaptureDevicePosition.front {
            session.removeInput(session.inputs.first as! AVCaptureInput!)
            
            if let availableBackDevice = self.defaultDevice(position: AVCaptureDevicePosition.back) {
                self.currentCaptureDevice = availableBackDevice
                do {
                    try session.addInput(AVCaptureDeviceInput(device: availableBackDevice))
                } catch {
                    print("No front camera")
                    return
                }
                
            }
        } else {
            print("error:: can't switch camera")
            return
        }
        session.startRunning()
    }
    
    func didPressTakePhoto() {
        guard onEdit == false else {
            dismissKeyboard()
            return
        }
        
        // retake
        if self.imageView.isHidden == false {
            self.imageView.isHidden = true
            return
        }
        
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        print("available: \(settings.availablePreviewPhotoPixelFormatTypes)")
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                             kCVPixelBufferWidthKey as String: 400,
                             kCVPixelBufferHeightKey as String: 400]
        settings.previewPhotoFormat = previewFormat
        self.AVOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }
        
        if let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            let producedImage = UIImage(data: dataImage)?.imageByScalingAndCropping(for: CGSize(width: self.previewView.frame.width, height: previewView.frame.height))
            self.imageView.image = producedImage
            if self.currentCaptureDevice?.position == .front {
                self.imageView.transform = CGAffineTransform(scaleX: -1, y: 1)
            }
            self.imageView.isHidden = false
        }
    }
    
    func dismissKeyboard() {
        textView.resignFirstResponder()
        
        
    }
    
}

