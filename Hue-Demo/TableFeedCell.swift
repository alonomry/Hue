//
//  TableFeedCell.swift
//  Hue
//
//  Created by Omry Dabush on 11/01/2017.
//  Copyright © 2017 Omry Dabush. All rights reserved.
//

import UIKit
import Firebase

protocol followUserDelegate {
    func isFollowing(_ ownerUID : String)->()
}
protocol CommentButtonDelegate {
    func changeWindow(_ imageUID : String)->()
}



class TableFeedCell: UITableViewCell {

    
    @IBOutlet weak var uploadedImage: UIImageView!
    @IBOutlet weak var numOfLikes: UILabel!
    @IBOutlet weak var uploadedImageComments: UILabel!
    @IBOutlet weak var elapsedTimeSinceUpload: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    
    
    var delegate : CommentButtonDelegate?
    
    var imageUID : String?
    
    @IBAction func commentButtonWasPressed(_ sender: Any) {
        if let imageuid = imageUID {
            if (delegate != nil) {
                self.delegate?.changeWindow(imageuid)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}

class TableFeedHeader: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileUserName: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    
    
    var delegate : followUserDelegate?
    
    var userUID : String? = {
        if let user = Model.sharedInstance.getCurrentUser(){
            return user
        }
        return nil
    }()
    
    var OwnerUID : String?
    
    
    @IBAction func followButttonWasPressed(_ sender: Any) {
        
        
        if (userUID != nil && OwnerUID != nil) {
        
            
            if (delegate != nil) {
                self.delegate?.isFollowing(OwnerUID!)
            }
        
        let currentUserRef = FIRDatabase.database().reference().child("Users").child(userUID!).child("Following")
        let ownerRef = FIRDatabase.database().reference().child("Users").child(OwnerUID!).child("Followers")
        
            
            currentUserRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if (snapshot.hasChildren()){
                    if var followingList = snapshot.value as? [String] {
                        followingList.append(self.OwnerUID!)
                        currentUserRef.setValue(followingList)
                    }
                }
                else {
                    currentUserRef.setValue([self.OwnerUID])
                }
            })
            
            ownerRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if (snapshot.hasChildren()){
                    if var followersList = snapshot.value as? [String] {
                        followersList.append(self.OwnerUID!)
                        ownerRef.setValue(followersList)
                    }
                }
                else {
                    ownerRef.setValue([self.userUID])
                }
            })
            
            self.followButton.setTitle("unFollow", for: .normal)
            
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
