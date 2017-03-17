//
//  AddImageViewController.swift
//  Hue
//
//  Created by Omry Dabush on 29/12/2016.
//  Copyright © 2016 Omry Dabush. All rights reserved.
//

import UIKit
import Firebase
import Fusuma


class AddImageViewController: UIViewController, FusumaDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.hasVideo = false
        self.present(fusuma, animated: true, completion: nil)

    }
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        
        guard let userUID : String = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
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
                    let uploadTime = NSDate()
                    let upload = Image(imageUid : imageName ,url: imageDownloadURL, title: "", date: uploadTime , owner: userUID)
                    let userProfileRef = FIRDatabase.database().reference().child("Posts").child(imageName)
                    userProfileRef.setValue(upload.toAnyObject())
                   
                //Updating or Adding imageNmae to the user Posts array
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
        
        
        self.performSegue(withIdentifier: "unwindFromAddImage", sender: self)

    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {}
    
    func fusumaCameraRollUnauthorized() {
        print("camera roll unauthorized")
    }

    
    func fusumaDismissedWithImage(_ image: UIImage, source: FusumaMode) {
//        self.dismiss(animated: true, completion: nil)
    }
    
    func fusumaClosed() {
        self.performSegue(withIdentifier: "unwindFromAddImage", sender: self)
    }
}
