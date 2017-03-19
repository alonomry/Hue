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

        Model.sharedInstance.saveImage(image: image)
        
        
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
