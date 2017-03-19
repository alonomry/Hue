//
//  Extention.swift
//  Hue-Demo
//
//  Created by Omry Dabush on 24/12/2016.
//  Copyright © 2016 Omry Dabush. All rights reserved.
//

import UIKit
import Firebase

let imageCache = NSCache<NSString, UIImage>()

class CustomTextField: UITextField,Jitterable,Flashable {}

class CustomLable: UILabel,Jitterable,Flashable {}

//class GetProfileFromFireBase: UIViewController {
//    func getProfile(ProfileUID : String) {
//        let profileRef = FIRDatabase.database().reference()
//    }
//}

extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(urlString: String){
        
        self.image = nil
        
        if let cachedImage = imageCache.object(forKey: (urlString as NSString))  {
            self.image = cachedImage
            return
        }
        
        let imageURL = URL(string: urlString)
        
        
        URLSession.shared.dataTask(with: imageURL!, completionHandler: { (data, response, error) in
            if error != nil {
                print (error!)
                return
            }
            DispatchQueue.main.async(execute: {
                if let image = data {
                    if let downloadedImage = UIImage(data: image) {
                        imageCache.setObject(downloadedImage, forKey: (urlString as NSString))
                        self.image = downloadedImage
                    }
                }
            })
        }).resume()
    }
}

extension Notification.Name {
    public static let fetchNotification = Notification.Name(rawValue: "done_fetching")
    public static let newLogin = Notification.Name(rawValue : "login_occurred")
    public static let logout = Notification.Name(rawValue : "logout_occurred")
}


