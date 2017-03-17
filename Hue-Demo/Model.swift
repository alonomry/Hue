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
        modelSQL = ModelSQL()
        
        self.fetchFeed { (success) in
            //Posting a notification that the fetch has been completed
            if (success){
                NotificationCenter.default.post(name: .fetchNotification , object: nil)
            }
        }

    }


    var imageFeed =  [String : Image]()
    var profileFeed = [String : Profile]()
    var DBref : FIRDatabaseReference?
    private var modelFirebase: ModelFirebase?
    private var modelSQL : ModelSQL?
    
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
    
    private func fetchFeed(success: @escaping (Bool) ->()){
        
        var count : UInt = 0
        var firstFetch = true
        
        //checking if there is a usere connected
        guard let _ = modelFirebase?.getUser() else {
            return
        }
        
        self.getImageData { (imageData, imageUID, ownerID) in
            self.imageFeed[imageUID] = imageData
            self.getProfileData(uid: ownerID, success: { (profileData, numOfUsers) in
                if (self.profileFeed[ownerID] == nil){
                    self.profileFeed[ownerID] = profileData
                    profileData.addProfileToLocalDb(database: self.modelSQL?.database)
                    count = count + 1
                    if (count == numOfUsers){
                        print("DONE FETCHING")
                        firstFetch = false
                        success(true)
                    }
                }
                if (!firstFetch){
                    success(true)
                }
            })
        
        }

    }
    
    
    func getImageData(success : @escaping (Image, String, String) -> Void) {
        DBref?.child("Posts").queryLimited(toFirst: 30).observe(.childAdded, with: { (snapshot) in
            
            let imageID = snapshot.key
            if let dictionary = snapshot.value as? [String : Any]{
                let feedImage = Image(json: dictionary)
                if let ownerUID = dictionary["OwnerUID"] as? String {
                    success(feedImage, imageID, ownerUID)
                }

            }
        })
    }

    func getProfileData(uid : String , success: @escaping (Profile, UInt) -> Void){
        DBref?.child("Users").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let users = snapshot.value as? [String : Any] {
                if let dictionary = users[uid] as? [String : Any] {
                    let feedProfile = Profile(json: dictionary)
                    
                    //Sending the profile obj, num of childeren and their key value
                    success(feedProfile, snapshot.childrenCount)
                    
                }
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

extension NSDate {
    func dateToSQL() -> Double {
        return self.timeIntervalSince1970 * 1000
    }
}
