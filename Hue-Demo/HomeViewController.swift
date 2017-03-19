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
    
    @IBOutlet weak var loadingPage: UIActivityIndicatorView!
    @IBOutlet weak var mainFeedCollectioView: UICollectionView!

    @IBAction func logoutButtonWasPressed(_ sender: Any) {
        handleLogout()
    }
    
    var imagesObject =  [String : Image]()
    var profileObject = [String : Profile]()
    var images : Array<Image>?
    var profile : Array<Profile>?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.loadDataAfterFetch(_:)), name: .fetchNotification, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.loadDataForNewLogin(_:)), name: .newLogin, object: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingPage.stopAnimating()
        verifyLoginUser()
        setupNavBar()
    }
    
    func verifyLoginUser(){
        if Model.sharedInstance.validateCurrentUser() == false {
            let loginVC = storyboard?.instantiateViewController(withIdentifier: "loginVC") as? LoginController
            self.present(loginVC!, animated: true, completion: nil)
        }else {
            setupCollectionView()
        }
    }
    
    func handleLogout(){
        if (Model.sharedInstance.handleLogout()){
            let loginVC = storyboard?.instantiateViewController(withIdentifier: "loginVC") as? LoginController
            NotificationCenter.default.post(name: .logout, object: nil)
            self.dismiss(animated: true, completion: nil )
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
    
    func loadDataAfterFetch (_ notification : Notification){
        
        //Getting the Data from Model
        imagesObject = Model.sharedInstance.getImageDataAfterFetch()
        profileObject = Model.sharedInstance.getProfileDataAfterFetch()
        
        //Converting the image data to Array so we could iterate
        images = Array(imagesObject.values)
        
        if (mainFeedCollectioView != nil ){
            profile = Array(profileObject.values)
            loadingPage.stopAnimating()
            mainFeedCollectioView.reloadData()
        }
    }
    
    func loadDataForNewLogin (_ notification : Notification){
        
        Model.sharedInstance.fetchFeed(success: { (success) in
            if (success){
                //Getting the Data from Model
                self.imagesObject = Model.sharedInstance.getImageDataAfterFetch()
                self.profileObject = Model.sharedInstance.getProfileDataAfterFetch()
                
                //Converting the image data to Array so we could iterate
                self.images = Array(self.imagesObject.values)
                
                if (self.mainFeedCollectioView != nil ){
                    self.profile = Array(self.profileObject.values)
                    self.loadingPage.stopAnimating()
                    self.mainFeedCollectioView.reloadData()
                }
            }
        })
    }
    
    @IBAction func unwindFromSignUp(segue : UIStoryboardSegue){
    }
    
    @IBAction func unwindFromAddImage(segue : UIStoryboardSegue){
        self.mainFeedCollectioView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesObject.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionFeedCell", for: indexPath) as! CollectionFeedCell
        
        cell.profileImage.layer.cornerRadius = 22
        cell.profileImage.layer.masksToBounds = true
        
        if let imageData = images?[indexPath.row] {
            
            //loading the image
            if let imageURL = imageData.imageURL {
                Model.sharedInstance.getImage(urlStr: imageURL, callback: { (image) in
                    cell.uploadedImage.image = image
                  
                })
            }
            
            if let numOfLikes = imageData.numOfLikes {
                cell.numOfLikes.text = numOfLikes.stringValue
            }
            
        }
        
        
        if let profileUID = images?[indexPath.row].OwnerUID {
            if let profileData = profileObject[profileUID]{
    
                if let profileImageURL = profileData.profileImageURL {
                    Model.sharedInstance.getImage(urlStr: profileImageURL, callback: { (image) in
                        cell.profileImage.image = image
                    })
                }
                if let profileUserName = profileData.userName {
                    cell.profileName.text = profileUserName
                }
                
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

