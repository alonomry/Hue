//
//  Profile.swift
//  Hue-Demo
//
//  Created by Omry Dabush on 24/12/2016.
//  Copyright © 2016 Omry Dabush. All rights reserved.
//

import UIKit

class Profile: NSObject {

    var profileName : String?
    var profileImage : String?
    var profileDescription : String = ""
    var Followers : [String] = [""]
    var Following : [String] = [""]
    
    
    
    init(Name : String, profileimage : String) {
        profileName = Name
        profileImage = profileimage
    }
    
    func toAnyObject() -> AnyObject {
        let toAnyObject : [String : AnyObject] = ["Full_Name" : profileName as AnyObject,
                                                  "Profile_Image" : profileImage as AnyObject,
                                                  "Description" : profileDescription as AnyObject,
                                                  "num_Of_Followers" : Followers as AnyObject,
                                                  "num_Of_Following" : Following as AnyObject,
                                                  ]
        return toAnyObject as AnyObject
    }
}


