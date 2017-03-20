//
//  CommentsController.swift
//  Hue
//
//  Created by alon tal on 24/12/2016.
//  Copyright © 2016 Omry Dabush. All rights reserved.
//

import UIKit
import FirebaseDatabase

class CommentsController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIViewControllerTransitioningDelegate  {
    
    @IBOutlet weak var TextField: UITextField!
    @IBOutlet weak var SendButton: UIButton!
    @IBOutlet weak var CommentsTableView: UITableView!
    
    
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    var imageUID : String?
    var commentedProfileImage : String?
    var commentedProfileName : String?
    var commentsDictionary : [String : Comment]=[:]
    var comments : [Comment]?
    
    
    @IBAction func SendButtonWasPressed(_ sender: Any) {
        //Adding the Messege object to firbase database
        if let messegeContent = TextField.text, let imageuid = imageUID, let commentedprofileimage = commentedProfileImage , let commentedprofilename = commentedProfileName{
            let commentUID = NSUUID().uuidString
            let comment = Comment(imageuid: imageuid, commentuid : commentUID, commprofileImage: commentedprofileimage, commprofileName: commentedprofilename, comm: messegeContent)
            Model.sharedInstance.saveComment(comment: comment)
            
            
        }
        keyboardWillHide()
        TextField.text = ""
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(CommentsController.loadDataAfterFetch(_:)), name: .fetchNotification, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CommentsController.keyboardWillHide))
        view.addGestureRecognizer(tap)
        comments = Array(commentsDictionary.values)
        setupTableview()
    }
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(CommentsController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CommentsController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupTableview(){
        CommentsTableView.delegate = self
        CommentsTableView.dataSource = self
        
        let nib = UINib(nibName: "CommentsCell", bundle: nil)
        CommentsTableView.register(nib, forCellReuseIdentifier: "CommentsCell")
    }
    
    
    func loadDataAfterFetch (_ notification : Notification){
        if (self.CommentsTableView != nil){
            let updatedComments = Model.sharedInstance.getCommentsAfterFetch()
            
            if let newCommentsArray = Model.sharedInstance.getImageDataAfterFetch()[imageUID!]?.comments{
                if (!newCommentsArray.isEmpty){
                    for comm in newCommentsArray {
                        if (commentsDictionary[comm] == nil){
                            commentsDictionary[comm] = updatedComments[comm]
                            comments = Array(commentsDictionary.values)
                            
                            self.CommentsTableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsDictionary.count
    }
    
    func keyboardWillShow (notification : NSNotification){
        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                bottomLayoutConstraint.constant = keyboardSize.height - 50
                self.view.layoutIfNeeded()
                
            }
        }
    }
    
    func keyboardWillHide (){
        bottomLayoutConstraint.constant = 0
        view.endEditing(true)
        self.view.layoutIfNeeded()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsCell") as! CommentsCell
        
        cell.CommentProfileImage.layer.cornerRadius = 22
        cell.CommentProfileImage.layer.masksToBounds = true
        
        if let commentData = comments?[indexPath.row]{
            cell.Comment.text = commentData.comment
            cell.userNameLabel.text = commentData.commentedProfileName
            
            if let userCommentProfileURL = commentData.commentedProfileImage {
                Model.sharedInstance.getImage(urlStr: userCommentProfileURL, callback: { (image) in
                    cell.CommentProfileImage.image = image
                })
                
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    
}
