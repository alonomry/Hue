//
//  Comment.swift
//  Hue-Demo
//
//  Created by Omry Dabush on 24/12/2016.
//  Copyright © 2016 Omry Dabush. All rights reserved.
//

import UIKit

class Comment: NSObject {
    
    var imageUID : String?
    var commentedProfileImage : String?
    var commentedProfileName : String?
    var comment : String?

    init(imageuid : String, commprofileImage : String, commprofileName : String, comm : String) {
        imageUID = imageuid
        commentedProfileImage = commprofileImage
        commentedProfileName = commprofileName
        comment = comm
    }
    
}
