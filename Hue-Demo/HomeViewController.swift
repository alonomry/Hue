//
//  HomeViewController.swift
//  Hue-Demo
//
//  Created by Omry Dabush on 23/12/2016.
//  Copyright © 2016 Omry Dabush. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var mainFeedCollectioView: UICollectionView!

    @IBAction func logoutButtonWasPressed(_ sender: Any) {
        handleLogout()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        verifyLoginUser()
        setupNavBar()
        setupCollectionView()
    }
    
    func verifyLoginUser(){
        if Model.sharedInstance.validateCurrentUser() == false {
            let loginVC = storyboard?.instantiateViewController(withIdentifier: "loginVC") as? LoginController
            self.present(loginVC!, animated: true, completion: nil)
        }else {
            //already Loggedin
        }
    }
    
    func handleLogout(){
        if (Model.sharedInstance.handleLogout()){
            let loginVC = storyboard?.instantiateViewController(withIdentifier: "loginVC") as? LoginController
            self.present(loginVC!, animated: true, completion: nil)
        }
        
    }

    func setupNavBar(){
        let logo = UIImage(named: "logo")
        let imageView = UIImageView (image: logo)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: 38 , height: 20)
        navigationItem.titleView = imageView
    }
    func setupCollectionView(){
        mainFeedCollectioView.delegate = self
        mainFeedCollectioView.dataSource = self
        
    }
    
    @IBAction func unwindFromSignUp(segue : UIStoryboardSegue){
    }
    
    @IBAction func unwindFromAddImage(segue : UIStoryboardSegue){
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let nib = UINib(nibName: "collectionFeedCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "collectionFeedCell")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionFeedCell", for: indexPath) as! CollectionFeedCell
        cell.profileImage.layer.cornerRadius = 22
        cell.profileImage.layer.masksToBounds = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = view.frame.width * (5 / 4)
        return CGSize(width: view.frame.width, height: height + 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

}

