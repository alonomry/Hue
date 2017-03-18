//
//  Image.swift
//  Hue-Demo
//
//  Created by Omry Dabush on 24/12/2016.
//  Copyright © 2016 Omry Dabush. All rights reserved.
//

import UIKit
import FirebaseDatabase

class Image : NSObject {

    var imageUID : String?
    var imageURL : String?
    var imageTitle : String?
    var numOfLikes : NSNumber?
    var uploadDate : Date?
    
    var OwnerUID : String?
    var comments : [String : Comment]? = [:]
    
    override init() {}
    
    init(imageUid : String , url : String, title : String, date : Date, owner : String) {
        imageUID = imageUid
        imageURL = url
        imageTitle = title
        uploadDate = date
        OwnerUID = owner
    }

    init(imageuid : String ,url : String, title : String,  nOfLikes : NSNumber , Date : Date, owner : String , comm : [String : Comment]? ) {
        imageURL = url
        imageTitle = title
        numOfLikes = nOfLikes
        uploadDate = Date
        OwnerUID = owner
        comments = comm
    }
    
    
    init (json : Dictionary<String , Any>){
        imageUID = json["ImageUID"] as? String
        imageURL = json["Image_URL"] as? String
        imageTitle = json["Image_title"] as? String
        numOfLikes = json["num_of_likes"] as? NSNumber
        uploadDate = json["Upload_Date"] as? Date
        OwnerUID = json["OwnerUID"] as? String
        comments = json["Comments"] as? [String : Comment]
    }
    
    func toAnyObject() -> AnyObject{
        let toAnyObject : [String : AnyObject] = ["ImageUID" : imageUID as AnyObject,
                                                  "Image_URL" : imageURL as AnyObject,
                                                  "Image_title" : imageTitle as AnyObject,
                                                  "num_Of_likes" : numOfLikes as AnyObject,
                                                  "Upload_Date" : FIRServerValue.timestamp() as AnyObject,
                                                  "OwnerUID" : OwnerUID as AnyObject,
                                                  "Comments" : comments as AnyObject]
        
        return toAnyObject as AnyObject
    }
    
}
