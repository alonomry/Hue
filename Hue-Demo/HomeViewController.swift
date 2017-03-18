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
    
    var imageFeed =  [String : Image]()
    var profileFeed = [String : Profile]()
    var images : Array<Image>?
    var profile : Array<Profile>?
    
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
            imageFeed = Model.sharedInstance.getImageDataAfterFetch()
            profileFeed = Model.sharedInstance.getProfileDataAfterFetch()
            images = Array(imageFeed.values)
            profile = Array (profileFeed.values)
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
        
        let nib = UINib(nibName: "collectionFeedCell", bundle: nil)
        mainFeedCollectioView.register(nib, forCellWithReuseIdentifier: "collectionFeedCell")
        
    }
    
    @IBAction func unwindFromSignUp(segue : UIStoryboardSegue){
    }
    
    @IBAction func unwindFromAddImage(segue : UIStoryboardSegue){
        self.mainFeedCollectioView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let numOfPosts = images?.count {
            return numOfPosts
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionFeedCell", for: indexPath) as! CollectionFeedCell
        
        cell.profileImage.layer.cornerRadius = 22
        cell.profileImage.layer.masksToBounds = true
        
        if let imageData = images?[indexPath.row] {
            
            //loading the image
            if let imageURL = imageData.imageURL {
                cell.uploadedImage.loadImageUsingCacheWithUrlString(urlString: imageURL)
            }
            
            if let numOfLikes = imageData.numOfLikes {
                cell.numOfLikes.text = numOfLikes.stringValue
            }
            
        }
        
        if let profileData = profile?[indexPath.row] {
            if let profileImageURL = profileData.profileImageURL {
                cell.profileImage.loadImageUsingCacheWithUrlString(urlString: profileImageURL)
            }
            if let profileUserName = profileData.userName {
                cell.profileName.text = profileUserName
            }
        }
        
        
        
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

