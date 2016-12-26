//
//  SignupController.swift
//  Hue
//
//  Created by Omry Dabush on 26/12/2016.
//  Copyright © 2016 Omry Dabush. All rights reserved.
//

import UIKit

class SignupController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate{
    
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var fullNameTextField: UITextField!


    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    


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
        signupButton.layer.cornerRadius = 20
        profileImageButton.layer.masksToBounds = false
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
    
    
//Delegate methods of UIImagePickerController
    
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
    
//Delegate methods of theRSKImageCropViewController
    
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








