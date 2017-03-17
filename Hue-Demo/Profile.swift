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
    var userName :  String?
    var profileImageURL : String?
    var profileDiscription : String?
    var userPosts : [String]? = []
    var followers : [String]? = []
    var following : [String]? = []
    
    
    
    init(profileuid : String, username : String, Name : String, profileimage : String, discription : String) {
        profileUID = profileuid
        userName = username
        profileName = Name
        profileImageURL = profileimage
        profileDiscription = discription
        
    }
    
    init(profileuid :String, profilename : String, username : String, profileimage : String, discription : String, userposts : [String], userfollowers : [String], userfollowing : [String]) {
        profileUID = profileuid
        profileName = profilename
        userName = username
        profileImageURL = profileimage
        profileDiscription = discription
        userPosts = userposts
        followers = userfollowers
        following = userfollowing
    }
    
    init(json : Dictionary<String , Any>){
        profileUID = json["ProfileUID"] as? String
        profileName = json["Profile_Name"] as? String
        userName = json["User_Name"] as? String
        profileImageURL = json["Profile_Image"] as? String
        profileDiscription = json["Discription"] as? String
        userPosts = json["User_Posts"] as? [String]
        followers = json["Followers"] as? [String]
        following = json["Following"] as? [String]
        
    }
    
    func toAnyObject() -> AnyObject {
        let toAnyObject : [String : AnyObject] = ["ProfileUID" : profileUID as AnyObject,
                                                  "Profile_Name" : profileName as AnyObject,
                                                  "User_Name" : userName as AnyObject,
                                                  "Profile_Image" : profileImageURL as AnyObject,
                                                  "Discription" : profileDiscription as AnyObject,
                                                  "User_Posts" : userPosts as AnyObject,
                                                  "Followers" : followers as AnyObject,
                                                  "Following" : following as AnyObject,
                                                  ]
        return toAnyObject as AnyObject
    }
    
}


