//
//  Profile.swift
//  Hue-Demo
//
//  Created by Omry Dabush on 24/12/2016.
//  Copyright © 2016 Omry Dabush. All rights reserved.
//

import UIKit

class Profile: NSObject {
    
    var profileUID : String?
    var profileName : String?
    var profileImage : String?
    var profileDescription : String?
    
    var numOfPosts : NSNumber?
    var numOfFollowers : NSNumber?
    var numOfFollowing : NSNumber?
    
    
    func toAnyObject() -> AnyObject {
        let toAnyObject : [String : AnyObject] = ["UID" : profileUID as AnyObject, "Name" : profileName as AnyObject, "Description" : profileDescription as AnyObject]
        return toAnyObject as AnyObject
    }
}


