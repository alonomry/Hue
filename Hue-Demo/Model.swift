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
                self.imageFeed = Image.getAllImagesFromLocalDb(database: self.modelSQL?.database)!
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
        
        // get last update date from SQL
        var lastUpdateDate = LastUpdateTable.getLastUpdateDate(database: modelSQL?.database, table: Image.Image_TABLE)
        
        getImageData(lastUpdateDate: lastUpdateDate, success: { (imageData, imageUID) in
            
            if let imageURL = imageData.imageURL {
                self.modelFirebase?.getImageFromFirebase(url: imageURL, callback: { (image) in
                    if let imageFile = image {
                        self.saveImageToFile(image: imageFile, name: imageUID, sucsess: { (filePath) in
                            imageData.imageURL = filePath
                            imageData.addImageToLocalDb(database: self.modelSQL?.database)
                        })
                    }
                })
            }
            
            if let imageUploadDate = imageData.uploadDate{
                if lastUpdateDate == nil{
                    lastUpdateDate = imageUploadDate
                }
                else{
                    if lastUpdateDate!.compare(imageUploadDate) == ComparisonResult.orderedAscending{
                        lastUpdateDate = imageUploadDate
                    }
                }
            }
            
            self.getProfileData(success: { (profileData, numOfUsers) in
                
                
                
                if let ownerID = profileData.profileUID {
                    
                    if (self.profileFeed[ownerID] == nil){
                        self.profileFeed[ownerID] = profileData
                        profileData.addProfileToLocalDb(database: self.modelSQL?.database)
                        count = count + 1
                        if (count == numOfUsers){
                            if (lastUpdateDate != nil){
                                LastUpdateTable.setLastUpdate(database: self.modelSQL?.database, table: Image.Image_TABLE, lastUpdate: lastUpdateDate!)
                            }


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
        
        })

    }

    //get called in pullToRefresh
    func getMostRecentPost (lastUpdateDate: Date, success : @escaping (Bool) -> ()) {
        modelFirebase?.getImageData(lastUpdateDate: lastUpdateDate ,success: { (imageData, imageUID) in
            self.imageFeed[imageUID] = imageData
            success(true)
        })
    }
    
    func getImageData(lastUpdateDate: Date?, success : @escaping (Image, String) -> Void) {
        modelFirebase?.getImageData(lastUpdateDate: lastUpdateDate ,success: { (imageData, imageUID) in
            success(imageData, imageUID)
        })
    }

    
    func getProfileData(success: @escaping (Profile, UInt) -> Void){
       modelFirebase?.getProfileData(success: { (profileData, numOfUsers) in
            success(profileData, numOfUsers)
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

