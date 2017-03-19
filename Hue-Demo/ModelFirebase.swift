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
    
    func getImageData(lastUpdateDate: Date? ,success : @escaping ([String : Image]) -> Void) {
        var imagePosts = [String : Image]()
        
        let handler = {(snapshot : FIRDataSnapshot) in
            for child in snapshot.children.allObjects {
                if let post = child as? FIRDataSnapshot {
                    if let dictionary = post.value as? Dictionary<String, Any> {
                        let feedImage = Image(json: dictionary)
                        imagePosts[post.key] = feedImage
                    }
                }
            }
            success(imagePosts)
        }
        let DBref = FIRDatabase.database().reference().child("Posts")
        
        if (lastUpdateDate != nil){
            let fbQuery = DBref.queryOrdered(byChild:"Upload_Date").queryStarting(atValue:lastUpdateDate?.dateToSQL())
            fbQuery.observe(FIRDataEventType.value, with: handler)
        }else{
            DBref.queryLimited(toFirst: 15).observe(FIRDataEventType.value, with: handler)
        }
        
        
        
        
        
    }

    func getProfileData(success : @escaping ([String : Profile]) -> Void){
        
        var Profiles = [String : Profile]()
        
        let handler = {(snapshot : FIRDataSnapshot) in
            

            for child in snapshot.children.allObjects {
                if let user = child as? FIRDataSnapshot {
                    if let dictionary = user.value as? Dictionary<String, Any> {
                        let feedProfile = Profile(json: dictionary)
                        if let userUID = feedProfile.profileUID {
                            Profiles[userUID] = feedProfile
                        }
                    }
                }
            }
            success(Profiles)
        }
        let DBref = FIRDatabase.database().reference().child("Users")
        DBref.observe(FIRDataEventType.value, with: handler)
        
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
    
    func getImageFromFirebase(url:String, callback:@escaping (UIImage?)->Void){
        let ref = FIRStorage.storage().reference(forURL: url)
        ref.data(withMaxSize: 10000000, completion: {(data, error) in
            if (error == nil && data != nil){
                let image = UIImage(data: data!)
                callback(image)
            }else{
                callback(nil)
            }
        })
    }
    
    func getDataBaseReference()->FIRDatabaseReference{
        return FIRDatabase.database().reference()
    }
}
