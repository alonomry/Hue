//
//  ExploreController.swift
//  Hue
//
//  Created by Omry Dabush on 11/01/2017.
//  Copyright © 2017 Omry Dabush. All rights reserved.
//

import UIKit
import Firebase

class ExploreController: UIViewController, UITableViewDelegate, UITableViewDataSource, CommentButtonDelegate{
    
    let feedXib = UINib(nibName: "tableFeedCell", bundle: nil)
    let DBref =  FIRDatabase.database().reference()
    
    let uid = FIRAuth.auth()?.currentUser?.uid
    var imageFeed =  [String : Image]()
    var profileFeed = [String : Profile]()
    var commentFeed = [String : Comment]()
    var images : Array<Image>?
    var profile : Array<Profile>?
    var scrollToIndex : Int = 0

    @IBOutlet weak var mainTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SearchController.loadDataAfterFetch(_:)), name: .fetchNotification, object: nil)
        
        mainTableView.register(feedXib, forCellReuseIdentifier: "tableFeedCell")
        mainTableView.register(feedXib, forHeaderFooterViewReuseIdentifier: "tableFeedHeader")
        profile = Array(profileFeed.values)

        configurAssets()
        
    }
    
    func changeWindow(_ imageUID : String)->(){
        var imageComments : [String :Comment]? = [:]
        
        if let comments = imageFeed[imageUID]?.comments{
            for comm in comments{
                imageComments?[comm] = commentFeed[comm]
            }
            if let commentVC = storyboard?.instantiateViewController(withIdentifier: "CommentsController") as? CommentsController {
                if let imComm = imageComments{
                    if let userID = uid{
                        if let profileURL = profileFeed[userID]?.profileImageURL, let profileName = profileFeed[userID]?.profileName{
                            commentVC.commentsDictionary = imComm
                            commentVC.imageUID = imageUID
                            commentVC.commentedProfileImage = profileURL
                            commentVC.commentedProfileName = profileName
                            self.navigationController?.show(commentVC, sender: self)
                            
                        }
                        
                        
                    }
                }
            }
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillAppear(animated)
        mainTableView.reloadData()
//        let scrollTo = IndexPath(row: scrollToIndex, section: scrollToIndex)
//        mainTableView.scrollToRow(at: scrollTo, at: .middle, animated: true)

    }
    
    func configurAssets(){
        mainTableView.delegate = self
        mainTableView.dataSource = self
    }

    func loadDataAfterFetch (_ notification : Notification){
        //Getting the Data from Model
        imageFeed = Model.sharedInstance.getImageDataAfterFetch()
        profileFeed = Model.sharedInstance.getProfileDataAfterFetch()
        commentFeed = Model.sharedInstance.getCommentsAfterFetch()
        
        images = Array(imageFeed.values)

        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "tableFeedCell") as! TableFeedCell
        cell.uploadedImage.contentMode = .scaleAspectFill
        
        let imageData = images?[indexPath.section]

        if let imageFeedURL = imageData?.imageURL{
            Model.sharedInstance.getImage(urlStr: imageFeedURL, callback: { (image) in
                cell.uploadedImage.image = image
                cell.imageUID = imageData?.imageUID
                cell.delegate = self
            })
        }
        if let numOfLikes = imageData?.numOfLikes?.stringValue {
            cell.numOfLikes.text = numOfLikes
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let header = Bundle.main.loadNibNamed("tableFeedHeader", owner: self, options: nil)?.first as! TableFeedHeader
        header.profileImage.layer.cornerRadius = 22
        header.profileImage.layer.masksToBounds = true
        
        header.followButton.layer.borderWidth = 1
        header.followButton.layer.borderColor = UIColor.black.cgColor
        header.followButton.layer.cornerRadius = 10
        header.followButton.layer.masksToBounds = true
        
        
        
        if let profileUID = images?[section].OwnerUID {
            header.OwnerUID = profileUID
            if let profileData = profileFeed[profileUID] {
                header.profileUserName.text = profileData.userName
                if let profileImagURL = profileData.profileImageURL{
                    header.profileImage.loadImageUsingCacheWithUrlString(urlString: profileImagURL)
                }
            }
        }
        
        return header
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
    
    func transition(sender: UIButton!){
        let commentview = storyboard?.instantiateViewController(withIdentifier: "CommentsController") as! CommentsController
        self.navigationController?.show(commentview, sender: self)
    }
    
    
}
