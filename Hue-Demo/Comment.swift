//
//  Comment.swift
//  Hue-Demo
//
//  Created by Omry Dabush on 24/12/2016.
//  Copyright © 2016 Omry Dabush. All rights reserved.
//

import UIKit

class Comment: NSObject {
    
    var commentUID : String?
    var imageUID : String?
    var commentedProfileImage : String?
    var commentedProfileName : String?
    var comment : String?
    
    
    init(imageuid : String, commentuid : String, commprofileImage : String, commprofileName : String, comm : String) {
        imageUID = imageuid
        commentUID = commentuid
        commentedProfileImage = commprofileImage
        commentedProfileName = commprofileName
        comment = comm
    }
    
    init(json : Dictionary<String , Any>){
        commentUID = json["CommentUID"] as? String
        imageUID = json["ImageUID"] as? String
        commentedProfileImage = json["CommentedProfileImage"] as? String
        commentedProfileName = json["CommentedProfileName"] as? String
        comment = json["Comment"] as? String
    }
    
    
    func toAnyObject() -> AnyObject{
        let toAnyObject : [String : AnyObject] = ["CommentUID" : commentUID as AnyObject,
                                                  "ImageUID" : imageUID as AnyObject,
                                                  "CommentedProfileImage" : commentedProfileImage as AnyObject,
                                                  "CommentedProfileName" : commentedProfileName as AnyObject,
                                                  "Comment" : comment as AnyObject]
        
        return toAnyObject as AnyObject
    }
    
    
}
