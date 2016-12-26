//
//  SecondViewController.swift
//  Hue-Demo
//
//  Created by Omry Dabush on 23/12/2016.
//  Copyright © 2016 Omry Dabush. All rights reserved.
//

import UIKit

class SearchCollectionViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    @IBOutlet weak var searchNavBar: UINavigationItem!
    @IBOutlet weak var searchCollectionView: UICollectionView!
  //  var images:[Picture]?
    var index:NSIndexPath?
 

     override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func setupCollectionView(){
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
    }
    
        override func viewDidLayoutSubviews(){
            super.viewDidLayoutSubviews()
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        }
        
        
        
//        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//            if(segue.identifier == "ExploreVC"){
//                let explorevc = segue.destination as! ExploreController
//                explorevc.images = self.images
//                explorevc.index = self.searchCollectionView.indexPath(for: sender as! UICollectionViewCell) as NSIndexPath?
//                           }
//        }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let secondview = storyboard?.instantiateViewController(withIdentifier: "ExploreController") as! ExploreController
        
        self.navigationController?.show(secondview, sender: self)
        
    }
    
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//            return images.count
            return 6
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let nib = UINib(nibName: "SearchCell", bundle: nil)
            collectionView.register(nib, forCellWithReuseIdentifier: "SearchCell")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCell", for: indexPath) as! SearchCell
            
            cell.SearchImageCell.backgroundColor = UIColor.gray

            
      //      imageView.image = images[indexPath.item].picture
            
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

