//
//  Helper.swift
//  cloub
//
//  Created by Chan Hee Park on 10/27/16.
//  Copyright © 2016 Chan Hee Park. All rights reserved.
//

import UIKit


class Util {
    class func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    class func generateRandomStringWithLength(len: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        let randomString : NSMutableString = NSMutableString(capacity: len)
        
        for _ in 0..<len {
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.character(at: Int(rand)))
        }
        
        return randomString as String
    }
}

class Time {
    class func firebaseTimeIntervalToNSDate(timeInterval: TimeInterval) -> Date {
        return Date(timeIntervalSince1970: -1 * timeInterval / 1000)
    }
    
    class func NSDateRightNowToFirebaseTimeInterval() -> TimeInterval {
        return Date().timeIntervalSince1970 * -1000
    }
    
    class func prettyDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        formatter.locale = NSLocale.current
        return formatter.string(from: date)
    }
    
    
    // This returns a string that indicates how much time it passed from a given NSDate object.
    class func stringForHowLongAgo(date: Date) -> String {
        let rightNow = Date()
        let intervalInSec = rightNow.timeIntervalSince(date as Date)
        let intervalInMonths = intervalInSec/3600/24/30
        let intervalInWeeks = intervalInSec/3600/24/7
        let intervalInDays = intervalInSec/3600/24
        let intervalInHours = intervalInSec/3600
        let intervalInMinutes = intervalInSec/60
        
        if intervalInMonths > 1 {
            let n = Int(intervalInMonths)
            if n > 1 {
                return "\(n) months ago"
            } else {
                return "A month ago"
            }
        } else if intervalInWeeks > 1 {
            let n = Int(intervalInWeeks)
            if n > 1 {
                return "\(n) weeks ago"
            } else {
                return "A week ago"
            }
        } else if intervalInDays > 1 {
            let n = Int(intervalInDays)
            if n > 1 {
                return "\(n) days ago"
            } else {
                return "Yesterday"
            }
        } else if intervalInHours > 1 {
            let n = Int(intervalInHours)
            if n > 1 {
                return "\(n) hours ago"
            } else {
                return "An hour ago"
            }
        } else if intervalInMinutes > 1 {
            let n = Int(intervalInMinutes)
            if n > 1 {
                return "\(n) minutes ago"
            } else {
                return "A minute ago"
            }
        } else {
            return "Just now"
        }
        
        
    }
    
    // This function returns true if it passed less than the given seconds
    class func hasBeenLessThanTime(sec: TimeInterval,from date: Date) -> Bool{
        let rightNow = Date()
        let timePassed = rightNow.timeIntervalSince(date)
        if timePassed < sec {
            return true
        } else {
            return false
        }
    }

    
}
