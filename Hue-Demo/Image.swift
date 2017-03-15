//
//  Image.swift
//  Hue-Demo
//
//  Created by Omry Dabush on 24/12/2016.
//  Copyright © 2016 Omry Dabush. All rights reserved.
//

import UIKit

class Image : NSObject {

    var imageURL : String?
    var imageTitle : String?
    var numOfLikes : NSNumber?
    var uploadDate : NSDate?
    
    var ownerUID : String?
    var comments : [String : Comment]? = [:]
    
    override init() {}
    
    init(url : String, title : String, date : NSDate, owner : String) {
        imageURL = url
        imageTitle = title
        uploadDate = date
        ownerUID = owner
    }
    
    init (json : Dictionary<String , Any>){
        imageURL = json["Image_URL"] as? String
        imageTitle = json["Image_title"] as? String
        numOfLikes = json["num_of_likes"] as? NSNumber
        uploadDate = json["Upload_Date"] as? NSDate
        ownerUID = json["OwnerUID"] as? String
        comments = json["Comments"] as? [String : Comment]
    }
    
    func toAnyObject() -> AnyObject{
        let toAnyObject : [String : AnyObject] = ["Image_URL" : imageURL as AnyObject,
                                                  "Image_title" : imageTitle as AnyObject,
                                                  "num_Of_likes" : numOfLikes as AnyObject,
                                                  "Upload_Date" : uploadDate?.description as AnyObject,
                                                  "OwnerUID" : ownerUID as AnyObject,
                                                  "Comments" : comments as AnyObject]
        
        return toAnyObject as AnyObject
    }
    
}
