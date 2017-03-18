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
    
    func getCurrentUser() -> String? {
        if let user = modelFirebase?.getUser() {
             return user.uid
        }
        return nil
    }
    
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
        
        getImageData { (imageData, imageUID) in
            self.imageFeed[imageUID] = imageData
            self.getProfileData(success: { (profileData, numOfUsers) in
                
                if let ownerID = profileData.profileUID {
                    
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
                }
            })
        
        }

    }

    //get called in pullToRefresh
    func getMostRecentPost (success : @escaping (Bool) -> ()) {
        getImageData { (imageData, imageUID) in
            self.imageFeed[imageUID] = imageData
            success(true)
        }
    }
    
    func getImageData(success : @escaping (Image, String) -> Void) {
        modelFirebase?.getImageData(success: { (imageData, imageUID) in
            success(imageData, imageUID)
        })
    }

    
    func getProfileData(success: @escaping (Profile, UInt) -> Void){
       modelFirebase?.getProfileData(success: { (profileData, numOfUsers) in
            success(profileData, numOfUsers)
       })
    }
    
    func saveImage(image : UIImage) {
        modelFirebase?.saveImageToFireBase(image: image, success: { (imageUID) in
            
        })
    }
    
    
    func getImageDataAfterFetch() ->[String : Image]{
        return imageFeed
    }
    
    func getProfileDataAfterFetch() -> [String : Profile]{
        return profileFeed
    }
    
    func getFireBaseReference() -> FIRDatabaseReference? {
            return DBref
    }
    
}

extension Date {
    func dateToSQL() -> Double {
        return self.timeIntervalSince1970 * 1000
    }
}
