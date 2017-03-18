//
//  SearchController.swift
//  Hue-Demo
//
//  Created by Omry Dabush on 23/12/2016.
//  Copyright © 2016 Omry Dabush. All rights reserved.
//

import UIKit

class SearchController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    @IBOutlet weak var searchNavBar: UINavigationItem!
    @IBOutlet weak var searchCollectionView: UICollectionView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    
    let DBref =  Model.sharedInstance.getFireBaseReference()
    var imagesObject : [String : Image] = [:]
    var profileObject : [String : Profile] = [:]
    var index: NSIndexPath?
    var didRemove = false
    var images : Array<Image>?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchController.loadDataAfterFetch(_:)), name: .fetchNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingIndicator.startAnimating()
        
        //removing all the posts from users that we are following
        removeMyFollowingFromFeed { (success) in
            if (success){
                self.images = Array(self.imagesObject.values)
                self.loadingIndicator.stopAnimating()
                self.setupCollectionView()
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    func setupCollectionView(){
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
        
        searchCollectionView.refreshControl = UIRefreshControl()
        searchCollectionView.refreshControl?.addTarget(self, action: #selector(self.handleRefresh(_:)), for: .valueChanged)
        
        
        let nib = UINib(nibName: "SearchCell", bundle: nil)
        searchCollectionView.register(nib, forCellWithReuseIdentifier: "SearchCell")
        
        searchCollectionView.reloadData()
        
    }
    
    func loadDataAfterFetch (_ notification : Notification){

        //Getting the Data from Model
        imagesObject = Model.sharedInstance.getImageDataAfterFetch()
        profileObject = Model.sharedInstance.getProfileDataAfterFetch()
        
        //Converting the image data to Array so we could iterate
        images = Array(imagesObject.values)
        
        if (self.searchCollectionView != nil) {
            self.searchCollectionView.reloadData()
        }

    }
    
    func removeMyFollowingFromFeed(success : @escaping (Bool)->()){
        
        if let myUserUID = Model.sharedInstance.getCurrentUser() {
            self.DBref?.child("Users").child(myUserUID).child("Following").observeSingleEvent(of: .value, with: { (snapshot) in
                if (snapshot.hasChildren()){
                    if let followingUsers  = snapshot.value as? [String] {
                        for user in followingUsers {
                            self.removeImagesFromfeed(userFeedToRemove: user, success: { (isRemoved, numOfPosts) in
                                if (isRemoved){
                                    success(true)
                                }
                            })
                        }
                    }
                }else {
                    //the user does not follow anyone
                    success(true)
                }
            }) { (error) in
                print(error)
            }
        }
    }
    
    func removeImagesFromfeed(userFeedToRemove : String, success : @escaping (Bool,Int) ->()){
        self.DBref?.child("Users").child(userFeedToRemove).child("User_Posts").observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.hasChildren()){
                if let userPosts = snapshot.value as? [String] {
                    for post in userPosts {
                        self.imagesObject.removeValue(forKey: post)
                        success(true, userPosts.count)
                    }
                }
            }
        }) { (error) in
            print(error)
        }
        
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        
        Model.sharedInstance.getMostRecentPost { (success) in
            if (success){
                self.searchCollectionView.reloadData()
                self.images = Array(self.imagesObject.values)
                print("REFRESHED")
                refreshControl.endRefreshing()
                NotificationCenter.default.post(name: .fetchNotification, object: nil)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let exploreVC = storyboard?.instantiateViewController(withIdentifier: "ExploreController") as? ExploreController {
            exploreVC.imageFeed = imagesObject
            exploreVC.profileFeed = profileObject
            exploreVC.images = images
            exploreVC.scrollToIndex = indexPath.row
            self.navigationController?.show(exploreVC, sender: self)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let postsArraySize = images?.count{
            return postsArraySize
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCell", for: indexPath) as! SearchCell
        if let cellImage = images?[indexPath.row].imageURL {
            cell.SearchImageCell.loadImageUsingCacheWithUrlString(urlString: cellImage)
        }
        
        return cell
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.width)/3-1, height: (view.frame.width)/3-1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
}

extension Notification.Name {
    public static let fetchNotification = Notification.Name(rawValue: "done_fetching")
}

