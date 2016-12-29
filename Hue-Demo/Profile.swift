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
    var profileDescription : String = ""
    
    var Posts : [Image] = []
    var Followers : [String] = []
    var Following : [String] = []
    
    init(uid : String, Name : String, profileimage : String) {
        profileUID = uid
        profileName = Name
        profileImage = profileimage
    }
    
    func toAnyObject() -> AnyObject {
        let toAnyObject : [String : AnyObject] = ["UID" : profileUID as AnyObject,
                                                  "Full_Name" : profileName as AnyObject,
                                                  "Profile_Image" : profileImage as AnyObject,
                                                  "Description" : profileDescription as AnyObject,
                                                  "num_Of_Posts" : Posts.count as AnyObject,
                                                  "num_Of_Followers" : Followers as AnyObject,
                                                  "num_Of_Following" : Following as AnyObject,
                                                  ]
        return toAnyObject as AnyObject
    }
}


