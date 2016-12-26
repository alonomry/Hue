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
    
    func handleLogout(){
        do{
            try FIRAuth.auth()?.signOut()
        }catch let logoutError{
            print(logoutError)
        }
        let loginVC = storyboard?.instantiateViewController(withIdentifier: "loginVC") as? LoginController
        self.present(loginVC!, animated: true, completion: nil)
        
    }


    func verifyLoginUser(){
        let user = FIRAuth.auth()?.currentUser
        if (user?.uid == nil){
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }else{
            //already loggedin
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        verifyLoginUser()
        setupNavBar()
        setupCollectionView()
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
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let nib = UINib(nibName: "feedCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "feedCell")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "feedCell", for: indexPath) as! FeedCell
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

