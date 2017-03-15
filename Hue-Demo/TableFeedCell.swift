//
//  TableFeedCell.swift
//  Hue
//
//  Created by Omry Dabush on 11/01/2017.
//  Copyright © 2017 Omry Dabush. All rights reserved.
//

import UIKit

class TableFeedCell: UITableViewCell {

    
    @IBOutlet weak var uploadedImage: UIImageView!
    
    @IBOutlet weak var numOfLikes: UILabel!
    @IBOutlet weak var uploadedImageComments: UILabel!
    @IBOutlet weak var elapsedTimeSinceUpload: UILabel!
    
    @IBOutlet weak var commentButton: UIButton!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}

class TableFeedHeader: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileUserName: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
