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
    
    init() {
        //Connecting to FireBase
        FIRApp.configure()
    }

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
    
    func getImageData(success : @escaping (Image, String) -> Void) {
        FIRDatabase.database().reference().child("Posts").queryLimited(toFirst: 15).observe(.childAdded, with: { (snapshot) in
            
            let imageID = snapshot.key
            if let dictionary = snapshot.value as? [String : Any]{
                let feedImage = Image(json: dictionary)
                success(feedImage, imageID)
            }
        })
        
    }
    
    func getProfileData(success : @escaping (Profile, UInt) -> Void){
        FIRDatabase.database().reference().child("Users").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let users = snapshot.value as? [String : Any] {
                for user in users {
                    if let userProfile = user.value as? [String : Any]{
                        let feedProfile = Profile(json: userProfile)
                        
                        //Sending the profile obj, num of childeren
                        success(feedProfile, snapshot.childrenCount)
                    }
                }
            }
        })
    }
    
    func saveImageToFireBase(image : UIImage, success : @escaping (String)->()){
        
        if let userUID = getUser()?.uid {
            
                    //Adding the image to firebase storage
                    let metaData = FIRStorageMetadata()
                    let imageName = NSUUID().uuidString
                    let userUploadRef = FIRStorage.storage().reference().child(userUID).child("Uploads").child("\(imageName).jpeg")
                    if let userData = UIImageJPEGRepresentation(image, 0.8){
                        metaData.contentType = "image/jpeg"
                        userUploadRef.put(userData, metadata: metaData, completion: { (metadata : FIRStorageMetadata?, error : Error?) in
                            if error != nil{
                                print(error!)
                                return
                            }
            
                            //Adding the image object to firbase database
                            if let imageDownloadURL = metadata?.downloadURL()?.absoluteString{
                                let uploadTime = Date()
                                let upload = Image(imageUid : imageName ,url: imageDownloadURL, title: "", date: uploadTime , owner: userUID)
                                let userProfileRef = FIRDatabase.database().reference().child("Posts").child(imageName)
                                userProfileRef.setValue(upload.toAnyObject())
            
                            //Updating or Adding imageName to the user Posts array
                                let userPostsRef = FIRDatabase.database().reference().child("Users").child(userUID).child("User_Posts")
            
                                userPostsRef.observeSingleEvent(of: .value, with: { (snapshot) in
                                    if (snapshot.hasChildren()){
                                        if var userPosts = snapshot.value as? [String] {
                                            userPosts.append(imageName)
                                            userPostsRef.setValue(userPosts)
                                        }
                                    }
                                    else {
                                        userPostsRef.setValue([imageName])
                                    }
                                })
                            }
                            
                        })
                    }
        }
    }
    
    func getDataBaseReference()->FIRDatabaseReference{
        return FIRDatabase.database().reference()
    }
    
}
