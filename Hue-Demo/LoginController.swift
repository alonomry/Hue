//
//  LoginController.swift
//  Hue
//
//  Created by Omry Dabush on 24/12/2016.
//  Copyright © 2016 Omry Dabush. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    
    
    @IBOutlet weak var mailTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    
    @IBOutlet weak var errorLabel: CustomLable!
    
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func loginButtonWasPressed(_ sender: Any) {
        if ((mailTextField.text?.isEmpty)! || (passwordTextField.text?.isEmpty)!) {
            self.loginErrorHandle(error: "All Fields Are Requiered")
        }else{
            FIRAuth.auth()?.signIn(withEmail: mailTextField.text!, password: passwordTextField.text!, completion: { (user : FIRUser?, error :Error?) in
                if (error != nil){
                    self.loginErrorHandle(error: "Wrong Email or Password")
                }else{
                    UIApplication.shared.statusBarStyle = .default
                    self.dismiss(animated: true, completion: { 
                        NotificationCenter.default.post(name: .newLogin, object: nil)
                    })
                }
            })
        }
    }
    
    func loginErrorHandle(error : String){
        self.mailTextField.Jitter()
        self.passwordTextField.Jitter()
        self.errorLabel.text = error
        self.errorLabel.flash()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAssets()
    }
    
    func configureAssets(){
        UIApplication.shared.statusBarStyle = .lightContent
        errorLabel.alpha = 0
        loginButton.layer.cornerRadius = 20
        
    }
    
}
