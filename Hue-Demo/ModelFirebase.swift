//
//  ModelFirebase.swift
//  Hue
//
//  Created by Omry Dabush on 27/01/2017.
//  Copyright © 2017 Omry Dabush. All rights reserved.
//

import UIKit
import Firebase

class ModelFirebase{
    

    func getUser()->FIRUser?{
        if let user = FIRAuth.auth()?.currentUser{
            return user
        }
        return nil
    }
    
    func logout()->Error? {
        do{
            try FIRAuth.auth()?.signOut()
        }catch let error{
            print(error)
            return error as Error
        }
        return nil
    }
    
}
