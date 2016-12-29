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
    var numOfLikes : NSNumber = 0
    var uploadDate : NSDate?
    
    var OwnerUID : String?
    var comments : [Comment] = []
    
    
    init(url : String, title : String, date : NSDate, owner : String) {
        imageURL = url
        imageTitle = title
        uploadDate = date
        OwnerUID = owner
    }
    
    func toAnyObject() -> AnyObject{
        let toAnyObject : [String : AnyObject] = ["Image_URL" : imageURL as AnyObject,
                                                  "Image_title" : imageTitle as AnyObject,
                                                  "num_Of_likes" : numOfLikes as AnyObject,
                                                  "Upload_Date" : uploadDate?.description as AnyObject,
                                                  "OwnerUID" : OwnerUID as AnyObject,
                                                  "Image_comments" : comments as AnyObject]
        
        return toAnyObject as AnyObject
    }
    
}
