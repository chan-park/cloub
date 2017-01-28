//
//  BaseExtension.swift
//  cloub
//
//  Created by Chan Hee Park on 10/20/16.
//  Copyright © 2016 Chan Hee Park. All rights reserved.
//

import Foundation
import UIKit
import MapKit
let imageCache = NSCache<AnyObject, AnyObject>()

extension UILabel {
    func useSFUIFont(withSize size: Float, andStyle style: String) {
        if style == "bold" {
            self.font = UIFont(name: "SFUIText-Bold", size: CGFloat(size))
        } else if style == "thin" {
            self.font = UIFont(name: "SFUIDisplay-Thin", size: CGFloat(size))
        } else if style == "regular" {
            self.font = UIFont(name: "SFUIDisplay-Regular", size: CGFloat(size))
        } else if style == "black" {
            self.font = UIFont(name: "SFUIDisplay-Black", size: CGFloat(size))
        } else {
            print("error:: Don't have \(style) font")
        }
    }
    
    
}

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
    static func appleBlue() -> UIColor {
        return UIColor.init(colorLiteralRed: 14.0/255, green: 122.0/255, blue: 254.0/255, alpha: 1.0)
    }
}

extension MKAnnotationView {
    
    func loadImageUsingCacheWithString(urlString: String, completionHandler: ((Bool)->())?) {
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage{
            self.image = cachedImage
            self.layer.masksToBounds = true
            self.layer.borderWidth = 3
            self.layer.borderColor = UIColor.white.cgColor
            if let completionHandler = completionHandler {
                completionHandler(true)
            }
            return
        }
        
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print("error at SeePostViewController.downloadPicture:: \(error)")
            }
            
            DispatchQueue.main.async {
                
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    self.image = downloadedImage
                    self.layer.masksToBounds = true
                    self.layer.borderWidth = 3
                    self.layer.borderColor = UIColor.white.cgColor
                    self.clipsToBounds = true
                    if let completionHandler = completionHandler {
                        completionHandler(true)
                    }
                } else {
                    if let completionHandler = completionHandler {
                        completionHandler(false)
                    }
                }
            }
            
            }.resume()
    }
}

extension UIImageView {
    func loadImageUsingCacheWithString(urlString: String, completionHandler: ((Bool)->())?) {
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage{
            self.image = cachedImage
            if let completionHandler = completionHandler {
                completionHandler(true)
            }
            return
        }
        
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print("error at SeePostViewController.downloadPicture:: \(error)")
            }
            
            DispatchQueue.main.async {
                
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    self.image = downloadedImage
                    if let completionHandler = completionHandler {
                        completionHandler(true)
                    }
                } else {
                    if let completionHandler = completionHandler {
                        completionHandler(false)
                    }
                }
            }
            
        }.resume()
    }
}


extension UIImage {
    func imageByScalingAndCropping(for targetSize: CGSize) -> UIImage {
        let sourceImage = self
        var newImage: UIImage? = nil
        let imageSize = sourceImage.size
        let width: CGFloat = imageSize.width
        let height: CGFloat = imageSize.height
        let targetWidth: CGFloat = targetSize.width
        let targetHeight: CGFloat = targetSize.height
        var scaleFactor: CGFloat = 0.0
        var scaledWidth: CGFloat = targetWidth
        var scaledHeight: CGFloat = targetHeight
        var thumbnailPoint = CGPoint(x: 0.0, y: 0.0)
        if imageSize.equalTo(targetSize) == false {
            let widthFactor: CGFloat = targetWidth / width
            let heightFactor: CGFloat = targetHeight / height
            if widthFactor > heightFactor {
                scaleFactor = widthFactor
                // scale to fit height
            }
            else {
                scaleFactor = heightFactor
                // scale to fit width
            }
            scaledWidth = width * scaleFactor
            scaledHeight = height * scaleFactor
            // center the image
            if widthFactor > heightFactor {
                thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5
            }
            else {
                if widthFactor < heightFactor {
                    thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5
                }
            }
        }
        UIGraphicsBeginImageContextWithOptions(targetSize, true, 0.0)
        // this will crop
        var thumbnailRect = CGRect.zero
        thumbnailRect.origin = thumbnailPoint
        thumbnailRect.size.width = scaledWidth
        thumbnailRect.size.height = scaledHeight
        sourceImage.draw(in: thumbnailRect)
        newImage = UIGraphicsGetImageFromCurrentImageContext()!
        if newImage == nil {
            print("could not scale image")
        }
        //pop the context to get back to the default
        UIGraphicsEndImageContext()
        return newImage!
    }
}

extension Int {
    
    func formatUsingAbbrevation () -> String {
        let numFormatter = NumberFormatter()
        
        typealias Abbrevation = (threshold:Double, divisor:Double, suffix:String)
        let abbreviations:[Abbrevation] = [(0, 1, ""),
                                           (1000.0, 1000.0, "K"),
                                           (100_000.0, 1_000_000.0, "M"),
                                           (100_000_000.0, 1_000_000_000.0, "B")]
        // you can add more !
        
        let startValue = Double (abs(self))
        let abbreviation:Abbrevation = {
            var prevAbbreviation = abbreviations[0]
            for tmpAbbreviation in abbreviations {
                if (startValue < tmpAbbreviation.threshold) {
                    break
                }
                prevAbbreviation = tmpAbbreviation
            }
            return prevAbbreviation
        } ()
        
        let value = Double(self) / abbreviation.divisor
        numFormatter.positiveSuffix = abbreviation.suffix
        numFormatter.negativeSuffix = abbreviation.suffix
        numFormatter.allowsFloats = true
        numFormatter.minimumIntegerDigits = 1
        numFormatter.minimumFractionDigits = 0
        numFormatter.maximumFractionDigits = 1
        
        return numFormatter.string(from: NSNumber (value:value))!
    }
    
}
