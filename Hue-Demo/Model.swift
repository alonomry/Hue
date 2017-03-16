//
//  Model.swift
//  Hue
//
//  Created by Omry Dabush on 03/02/2017.
//  Copyright © 2017 Omry Dabush. All rights reserved.
//

import UIKit
import Firebase

class Model{
    
    
    //Using this Model as Singlton
    static let sharedInstance = Model()
    
    
    private init(){
        modelFirebase = ModelFirebase()
        DBref = modelFirebase?.getDataBaseReference()
        
        self.fetchFeed()
        
        //Posting a notification that the fetch has been completed
//        NotificationCenter.default.post(name: .fetchNotification , object: nil)
    }
    

    var imageFeed =  [String : Image]()
    var profileFeed = [String : Profile]()
    var DBref : FIRDatabaseReference?
    private var modelFirebase: ModelFirebase?
    
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
    
    private func fetchFeed(){
        
        if let user = modelFirebase?.getUser(){
            print(user)
        }
        
        DBref?.child("Posts").observe(.childAdded, with: { (snapshot) in
    
            let imageID = snapshot.key

            if let dictionary = snapshot.value as? [String : Any]{
                let feedImage = Image(json: dictionary)
                if let ownerUID = dictionary["OwnerUID"] as? String {
                    self.getProfileData(uid: ownerUID, callback: { (profile) in
                        self.profileFeed[ownerUID] = profile
                    })
                }
                
                self.imageFeed[imageID] = feedImage

            }
        })
        
    }

    func getProfileData(uid : String , callback: @escaping (Profile) -> Void){
        DBref?.child("Users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let userProfile = snapshot.value as? [String : Any] {
                let feedProfile = Profile(json: userProfile)
                callback(feedProfile)
            }
        })
        
    }
    
    func getImageDataAfterFetch() ->[String : Image]{
        return imageFeed
    }
    
    func getProfileDataAfterFetch() -> [String : Profile]{
        return profileFeed
    }
    
}
