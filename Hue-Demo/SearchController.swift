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
    var commentObject : [String : Comment] = [:]
    var index: NSIndexPath?
    var didRemove = false
    var images : Array<Image>?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchController.loadDataAfterFetch(_:)), name: .fetchNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchController.logout(_:)), name: .logout, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingIndicator.startAnimating()
        
        loadNewFeed()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
        loadNewFeed()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func loadNewFeed(){
        //removing all the posts from users that we are following
        Model.sharedInstance.removeMyFollowingFromFeed({ (withoutFollowing) in
            if (!withoutFollowing.isEmpty){
                self.loadingIndicator.stopAnimating()
                self.images = Array (withoutFollowing.values)
                sleep(UInt32(0.09))
                self.setupCollectionView()
                self.searchCollectionView.reloadData()
            }else{
                self.loadingIndicator.stopAnimating()
                self.images = Array (self.imagesObject.values)
                sleep(UInt32(0.09))
                self.setupCollectionView()
                self.searchCollectionView.reloadData()
            }
        })
        
    }
    
    func setupCollectionView(){
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
        
        let nib = UINib(nibName: "SearchCell", bundle: nil)
        searchCollectionView.register(nib, forCellWithReuseIdentifier: "SearchCell")
        
        searchCollectionView.refreshControl = UIRefreshControl()
        searchCollectionView.refreshControl?.addTarget(self, action: #selector(self.handleRefresh(_:)), for: .valueChanged)
        
    }
    
    func loadDataAfterFetch (_ notification : Notification){

        //Getting the Data from Model
        imagesObject = Model.sharedInstance.getImageDataAfterFetch()
        profileObject = Model.sharedInstance.getProfileDataAfterFetch()
        commentObject = Model.sharedInstance.getCommentsAfterFetch()
        
        //Converting the image data to Array so we could iterate
        images = Array(imagesObject.values)
        
        if (self.searchCollectionView != nil) {
            self.searchCollectionView.reloadData()
        }

    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {

        loadNewFeed()
        refreshControl.endRefreshing()
        
//        Model.sharedInstance.getMostRecentPost(lastUpdateDate: nil) { (withoutFollowing) in
//            if (!withoutFollowing.isEmpty){
//                self.imagesObject = withoutFollowing
//                self.images = Array (withoutFollowing.values)
//                print("REFRESHED")
//                sleep(UInt32(0.01))
//                self.searchCollectionView.reloadData()
//                refreshControl.endRefreshing()
//            }else {
//                print("REFRESHED")
//                sleep(UInt32(0.01))
//                self.searchCollectionView.reloadData()
//                refreshControl.endRefreshing()
//            }
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let exploreVC = storyboard?.instantiateViewController(withIdentifier: "ExploreController") as? ExploreController {
            exploreVC.imageFeed = imagesObject
            exploreVC.profileFeed = profileObject
            exploreVC.commentFeed = commentObject
            exploreVC.images = images
            exploreVC.scrollToIndex = indexPath.row
            self.navigationController?.show(exploreVC, sender: self)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let numOfObjects = images?.count {
            return numOfObjects
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCell", for: indexPath) as! SearchCell
        if let cellImage = images?[indexPath.row].imageURL {
            Model.sharedInstance.getImage(urlStr: cellImage, callback: { (image) in
                cell.SearchImageCell.image = image
            })
        }
        
        return cell
    }
    
    func logout (_ notification : Notification){
        
        self.dismiss(animated: false, completion: nil)
        self.view.removeFromSuperview()
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


