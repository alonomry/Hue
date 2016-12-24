//
//  ExploreController.swift
//  Hue
//
//  Created by alon tal on 24/12/2016.
//  Copyright © 2016 Omry Dabush. All rights reserved.
//

import UIKit

class ExploreController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var ExploreCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        
    }
    
    func setupCollectionView(){
        ExploreCollectionView.delegate = self
        ExploreCollectionView.dataSource = self
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let nib = UINib(nibName: "feedCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "feedCell")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "feedCell", for: indexPath) as! FeedCell
        cell.profileImage.layer.cornerRadius = 22
        cell.profileImage.layer.masksToBounds = true
        
        cell.commentButton.addTarget(self, action: Selector(("transition")), for: .touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = view.frame.width * (5 / 4)
        return CGSize(width: view.frame.width, height: height + 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillAppear(animated)
    }
    
    
    func transition(sender: UIButton!){
        let commentview = storyboard?.instantiateViewController(withIdentifier: "CommentsController") as! CommentsController
        
        self.navigationController?.show(commentview, sender: self)
    }
    

    
}
