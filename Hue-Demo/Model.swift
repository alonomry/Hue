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
    var commentFeed = [String : Comment]()
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
        var didLogout = false
        modelFirebase?.logout(success: { (loggedOut) in
            didLogout = loggedOut
        })
        return didLogout
    }
    
    func fetchFeed(success: @escaping (Bool) ->()){
        
        var firstFetch = false
        
        //checking if there is a usere connected
        guard let _ = modelFirebase?.getUser() else {
            return
        }
        
        // get last update date from SQL
        var lastUpdateDate = LastUpdateTable.getLastUpdateDate(database: modelSQL?.database, table: Image.Image_TABLE)
        
        self.getImageData(lastUpdateDate: lastUpdateDate, success: { (imagePosts) in
            
            for image in imagePosts.values {
                
                //getting the image url and saving locally
                if let imageURL = image.imageURL {
                    self.modelFirebase?.getImageFromFirebase(url: imageURL, callback: { (imageFromFB) in
                        if let imageFile = imageFromFB {
                            if let imageUID = image.imageUID {
                                self.saveImageToFile(image: imageFile, name: imageUID, sucsess: { (filePath) in
                                    image.imageURL = filePath
                                    image.addImageToLocalDb(database: self.modelSQL?.database)
                                })
                            }
                        }
                    })
                }
                
                //checking the most recent upload date
                if let imageUploadDate = image.uploadDate{
                    if lastUpdateDate == nil{
                        lastUpdateDate = imageUploadDate
                        firstFetch = true
                    }
                    else{
                        
                        if lastUpdateDate!.compare(imageUploadDate) == ComparisonResult.orderedAscending{
                            lastUpdateDate = imageUploadDate
                        }
                    }
                }
            }
            
            
            if (lastUpdateDate != nil){
                LastUpdateTable.setLastUpdate(database: self.modelSQL?.database, table: Image.Image_TABLE, lastUpdate: lastUpdateDate!)
            }
            
            if (firstFetch){
                self.imageFeed = imagePosts
            }else{
                self.imageFeed = Image.getAllImagesFromLocalDb(database: self.modelSQL?.database)!
            }
            
            if (!firstFetch){
                success(true)
            }
        })
        
        self.getProfileData(success: { (profiles) in
            
            for profile in profiles.values {
                profile.addProfileToLocalDb(database: self.modelSQL?.database)
            }
            
            self.profileFeed = profiles
//            
//            print("DONE FETCHING")
//            success(true)
        })
        
        self.getComment(callback: {(comments) in
            
            for comment in comments.values {
                comment.addCommentToLocalDb(database: self.modelSQL?.database)
                
            }
            
            self.commentFeed = comments
            
            //            print("DONE FETCHING")
            success(true)
            
            
        })
    }
    
    
    
    //get called in pullToRefresh
    func getMostRecentPost (lastUpdateDate: Date?, success : @escaping ([String : Image]) -> ()) {
        modelFirebase?.getImageData(lastUpdateDate: nil ,success: { (imagePosts) in
            self.removeMyFollowingFromFeed({ (withoutFollowing) in
                if (!imagePosts.isEmpty){
                    success(withoutFollowing)
                }
            })
        })
    }
    
    //get called in pullToRefresh
//    func getMostRecentPost (lastUpdateDate: Date, success : @escaping (Bool) -> ()) {
//        modelFirebase?.getImageData(lastUpdateDate: lastUpdateDate ,success: { (imagePosts) in
//            self.imageFeed = imagePosts
//            success(true)
//        })
//    }
    
    func getImageData(lastUpdateDate: Date?, success : @escaping ([String : Image]) -> Void) {
        modelFirebase?.getImageData(lastUpdateDate: lastUpdateDate ,success: { (imagePosts) in
            success(imagePosts)
        })
    }
    
    
    func getProfileData(success: @escaping ([String : Profile]) -> Void){
        modelFirebase?.getProfileData(success: { (profiles) in
            success(profiles)
        })
    }
    
    func getImage(urlStr:String , callback:@escaping (UIImage)->Void){
        //1. try to get the image from local store
        let url = URL(string: urlStr)
        let lsatcomponent = url!.deletingPathExtension()
        let localImageName = lsatcomponent.lastPathComponent
        
        if let image = self.getImageFromFile(name: localImageName){
            callback(image)
        }else{
            //2. get the image from Firebase
            modelFirebase?.getImageFromFirebase(url: urlStr, callback: { (image) in
                if let imagefile = image{
                    //3. save the image localy
                    self.saveImageToFile(image: imagefile, name: localImageName, sucsess: { (filePath) in
                    })
                    //4. return the image to the user
                    
                    callback(imagefile)
                }
            })
        }
    }
    
    func saveImage(image : UIImage){
        
        //1.upload image to firebase storage and database
        modelFirebase?.saveImageToFireBase(image: image, success: { (imageUID) in
            //2. upload image to loacal storage
            self.saveImageToFile(image: image, name: imageUID, sucsess: { (filePath) in
                
            })
        })
        
    }
    
    func getComment( callback:@escaping ([String :Comment])->Void){
        modelFirebase?.getComments(success: { (coments) in
            callback(coments)
        })
    }
    
    func saveComment(comment : Comment){
        //1.upload comment to firebase database
        modelFirebase?.saveCommentToFireBase(comment: comment, success:{ (bool) in
            //2. upload comment to loacal storage
            comment.addCommentToLocalDb(database: self.modelSQL?.database)
        })
    }
    
    private func saveImageToFile(image:UIImage, name:String , sucsess : @escaping(String)->()){
        if let data = UIImageJPEGRepresentation(image, 0.8) {
            createDirectory(directoryName: name)
            let filePath = getDocumentsDirectory().appendingPathComponent("/\("Posts")/\(name)/\(name).jpg")
            try? data.write(to: filePath)
            sucsess(filePath.absoluteString)
        }
    }
    
    private func getImageFromFile(name:String)->UIImage?{
        let filename = getDocumentsDirectory().appendingPathComponent("\("Posts")/\(name)/\(name).jpg")
        return UIImage(contentsOfFile:filename.path)
    }
    
    func createDirectory(directoryName : String){
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("/\("Posts")/\(directoryName)")
        if !fileManager.fileExists(atPath: paths){
            try! fileManager.createDirectory(atPath: paths, withIntermediateDirectories: true, attributes: nil)
        }else{
            print("Directory already created")
        }
    }
    
    func removeMyFollowingFromFeed(_ success : @escaping ([String : Image])->()){
        var withoutFollowing = self.getImageDataAfterFetch()
        
        modelFirebase?.getMyFollowing(success: { (following) in
            print(following.isEmpty)
            if (!following.isEmpty){
                for user in following {
                    self.modelFirebase?.getUserPosts(userFeedToRemove: user, success: { (posts) in
                        if (!posts.isEmpty) {
                            for post in posts {
                                withoutFollowing.removeValue(forKey: post)
                            }
                            success(withoutFollowing)
                        }
                    })
                }
            }
        })
    }
    
    func getMyFollowoingFeed(_ success : @escaping (Bool)->()){
        var followingFeed = [String : Image]()
        modelFirebase?.getMyFollowing(success: { (following) in
            for user in following {
               self.modelFirebase?.getUserPosts(userFeedToRemove: user, success: { (posts) in
                for post in posts {
                    followingFeed[post] = self.imageFeed[post]
                }
                self.imageFeed = followingFeed
                success(true)
                NotificationCenter.default.post(name: .fetchNotification, object: nil)
               })
            }
        })
        
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in:
            .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    
    func getImageDataAfterFetch() ->[String : Image]{
        return imageFeed
    }
    
    func getProfileDataAfterFetch() -> [String : Profile]{
        return profileFeed
    }
    
    func getCommentsAfterFetch() -> [String : Comment]{
        return commentFeed
    }
    
    func getFireBaseReference() -> FIRDatabaseReference? {
        return DBref
    }
}

extension Date {
    func dateToSQL() -> Double {
        return self.timeIntervalSince1970 * 1000
    }
    
    var stringValue: String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: self as Date)
    }
    
    static func fromFirebase(_ interval:Double)->Date{
        if (interval>9999999999){
            return Date(timeIntervalSince1970: interval/1000)
        }else{
            return Date(timeIntervalSince1970: interval)
        }
    }
 
}

