//
//  Model.swift
//  Hue
//
//  Created by Omry Dabush on 03/02/2017.
//  Copyright © 2017 Omry Dabush. All rights reserved.
//

import UIKit

class Model{
    //Using this Model as Singlton
    static let sharedInstance = Model()
    
    private init(){}
    
    //Creating an Private instance of fireBaseModel
    lazy private var modelFirebase: ModelFirebase? = ModelFirebase()
    
    func validateCurrentUser()->Bool{
        if modelFirebase?.getUser() == nil {
            if handleLogout(){
                return false
            }
        }
        return true
    }
    
    func handleLogout()->Bool{
        if modelFirebase?.logout() == nil {
            return true
        }else{
            return false
        }
        
    }
    
}
