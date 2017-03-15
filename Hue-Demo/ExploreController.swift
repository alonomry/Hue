//
//  ExploreController.swift
//  Hue
//
//  Created by Omry Dabush on 11/01/2017.
//  Copyright © 2017 Omry Dabush. All rights reserved.
//

import UIKit
import Firebase

class ExploreController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    let feedXib = UINib(nibName: "tableFeedCell", bundle: nil)
    let uid = FIRAuth.auth()?.currentUser?.uid
    let DBref =  FIRDatabase.database().reference()
    var imageFeed =  [Image]()
    var profileFeed = [String : Profile]()
    
    
    
    @IBOutlet weak var mainTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTableView.register(feedXib, forCellReuseIdentifier: "tableFeedCell")
        mainTableView.register(feedXib, forHeaderFooterViewReuseIdentifier: "tableFeedHeader")
        fetchFeed()
        configurAssets()
        
    }
    
    func configurAssets(){
        mainTableView.delegate = self
        mainTableView.dataSource = self
    }
    
    func fetchFeed(){
        
        if let user = FIRAuth.auth()?.currentUser {
            print(user)
        }
        
        DBref.child("Posts").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : Any] {
            
                let feedImage = Image(json: dictionary)
                
                if let ownerUID = dictionary["OwnerUID"] as? String {
                    self.getProfileData(uid: ownerUID, callback: { (profile) in
                        self.profileFeed[ownerUID] = profile
                    })
                }
                
                self.imageFeed.append(feedImage)
                
                //reloading table view data asyncronicly to prevent crash
                DispatchQueue.main.async {

                    self.mainTableView.reloadData()
                    
                }
            }
        })
    }
    
    
    func getProfileData(uid : String , callback: @escaping (Profile) -> Void){
        DBref.child("Users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let userProfile = snapshot.value as? [String : Any] {
                let feedProfile = Profile(json: userProfile)
                callback(feedProfile)
            }
        })
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return imageFeed.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 62
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = tableView.frame.width * (5 / 4)
        return height + 150 - 63
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "tableFeedCell") as! TableFeedCell
        
        cell.uploadedImage.contentMode = .scaleAspectFill
        
        let imageData = imageFeed[indexPath.section]
        
        
        if let imageFeedURL = imageData.imageURL{
            cell.uploadedImage.loadImageUsingCacheWithUrlString(urlString: imageFeedURL)
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let header = Bundle.main.loadNibNamed("tableFeedHeader", owner: self, options: nil)?.first as! TableFeedHeader
        
        header.profileImage.layer.cornerRadius = 22
        header.profileImage.layer.masksToBounds = true
        
        if let profileUID = imageFeed[section].ownerUID {
            if let profileData = profileFeed[profileUID] {
                header.profileUserName.text = profileData.userName
                if let profileImagURL = profileData.profileImageURL{
                    header.profileImage.loadImageUsingCacheWithUrlString(urlString: profileImagURL)
                }
            }
        }
        
        return header
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
