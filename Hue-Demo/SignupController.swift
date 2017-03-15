//
//  SignupController.swift
//  Hue
//
//  Created by Omry Dabush on 26/12/2016.
//  Copyright © 2016 Omry Dabush. All rights reserved.
//

import UIKit
import Firebase

class SignupController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate{
    
    @IBOutlet weak var emailAddressTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var usernameTextField: CustomTextField!
    @IBOutlet weak var fullNameTextField: CustomTextField!

    @IBOutlet weak var errorLabel: CustomLable!

    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
 
    @IBAction func signupButtonWasPressed(_ sender: Any) {
        guard let email = emailAddressTextField, let password = passwordTextField, let userName = usernameTextField, let fullName = fullNameTextField else{
            return
        }
        let textFields = [email,password,userName,fullName]
        
        if validateEmptyFields(cutomTextFields: textFields) {
            errorLabel.text = "All field are required"
            errorLabel.flash()
        }else{
            handleRegister(email: email.text!, password: password.text!, userName: userName.text!, fullName: fullName.text!)
        }
        
    }


    @IBAction func pickProfileImageButtonWasPressed(_ sender: Any) {
        handleProfileImagePick()
    }
    
    @IBAction func signinButtonWasPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAssets()
    }
    
    func configureAssets(){
        errorLabel.alpha = 0
        signupButton.layer.cornerRadius = 20
        profileImageButton.layer.masksToBounds = false
    }
    
    func validateEmptyFields(cutomTextFields : [CustomTextField]) -> Bool{
        var emptyFieldsExist : Bool = false
        
        for item in cutomTextFields {
            if item.text?.isEmpty ?? false{
                item.Jitter()
                emptyFieldsExist = true
            }
        }
        return emptyFieldsExist
    }
    
    func handleRegister(email : String, password: String, userName : String, fullName : String){
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user : FIRUser?, error : Error?) in
            if (error != nil){
                self.errorLabel.text = error?.localizedDescription
                self.errorLabel.flash()
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            //Successfully authenticated new user, Now lets upload the new user to the DataBase
            
            let imageName = NSUUID().uuidString
            let storageRef = FIRStorage.storage().reference().child(uid).child("Profile_Image").child("\(imageName).jpg")
            
            if let uploadData = UIImageJPEGRepresentation(self.profileImageButton.currentImage!, 0.8){
                let metaData = FIRStorageMetadata()
                metaData.contentType = "image/jpeg"
                storageRef.put(uploadData, metadata: metaData, completion: { (metadata : FIRStorageMetadata?, error : Error?) in
                    if error != nil {
                        self.errorLabel.text = error?.localizedDescription
                        self.errorLabel.flash()
                        return
                    }
                    
                    if let profileImageURL = metadata?.downloadURL()?.absoluteURL {
                        let userProfile = Profile(username : userName, Name: fullName, profileimage: profileImageURL.absoluteString, discription : "bla bla")
                        let newUserRef = FIRDatabase.database().reference().child("Users").child(uid)
                        newUserRef.setValue(userProfile.toAnyObject())
                        self.performSegue(withIdentifier: "unwindFromSignup", sender: self)
                    }
                    
                })
            }
            
        })
        
        
    }
    
    func handleProfileImagePick(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Pick A Profile Image", message: "Choose An Image Source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action :UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
            print("Camera Not Available")
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action :UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel , handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
//Delegate methods of UIImagePickerController For picking profile image
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            picker.dismiss(animated: true, completion: {
                let imageCropVC = RSKImageCropViewController(image: pickedImage, cropMode: .circle)
                imageCropVC.delegate = self
                self.present(imageCropVC, animated: true, completion: nil)
            })
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
//Delegate methods of theRSKImageCropViewController ffor picking profile image
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        self.profileImageButton.setImage(croppedImage, for: .normal)
        self.profileImageButton.layer.cornerRadius = 44
        self.profileImageButton.layer.masksToBounds = true
        controller.dismiss(animated: true, completion: nil)
    }
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}








