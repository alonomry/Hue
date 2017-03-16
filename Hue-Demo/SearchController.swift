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
    
    
    
    var imagesObject : [String : Image] = [:]
    var profileObject : [String : Profile] = [:]
    var index: NSIndexPath?
    var images : Array<Image>?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchController.loadDataAfterFetch(_:)), name: .fetchNotification, object: nil)
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupCollectionView()
        
        //Getting the Data from Model
        imagesObject = Model.sharedInstance.getImageDataAfterFetch()
        profileObject = Model.sharedInstance.getProfileDataAfterFetch()
        
        //Converting the image data to Array so we could iterate
        images = Array(imagesObject.values)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    
//        if (imagesObject.count = 0 || profileObject.cout == 0){
//            imagesObject = Model.sharedInstance.getImageDataAfterFetch()
//            profileObject = Model.sharedInstance.getProfileDataAfterFetch()
//            searchCollectionView.reloadData()
//        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupCollectionView(){
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
        
        let nib = UINib(nibName: "SearchCell", bundle: nil)
        searchCollectionView.register(nib, forCellWithReuseIdentifier: "SearchCell")
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func loadDataAfterFetch (_ notification : Notification){
        imagesObject = Model.sharedInstance.getImageDataAfterFetch()
        profileObject = Model.sharedInstance.getProfileDataAfterFetch()
        searchCollectionView.reloadData()
    }
    
    //        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //            if(segue.identifier == "ExploreVC"){
    //                let explorevc = segue.destination as! ExploreController
    //                explorevc.images = self.images
    //                explorevc.index = self.searchCollectionView.indexPath(for: sender as! UICollectionViewCell) as NSIndexPath?
    //                           }
    //        }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let exploreVC = storyboard?.instantiateViewController(withIdentifier: "ExploreController") as? ExploreController {
            exploreVC.imageFeed = imagesObject
            exploreVC.profileFeed = profileObject
            self.navigationController?.show(exploreVC, sender: self)
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return imagesObject.count
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    
}

extension Notification.Name {
    public static let fetchNotification = Notification.Name(rawValue: "done_fetching")
}

