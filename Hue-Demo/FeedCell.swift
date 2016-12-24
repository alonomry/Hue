//
//  FeedCell.swift
//  Hue-Demo
//
//  Created by Omry Dabush on 24/12/2016.
//  Copyright © 2016 Omry Dabush. All rights reserved.
//

import UIKit

class FeedCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var uploadedImage: UIImageView!

    @IBOutlet weak var numOfLikes: UILabel!
    @IBOutlet weak var uploadedImageComments: UILabel!
    @IBOutlet weak var elapsedTimeSinceUpload: UILabel!
    
    
    var image : Image?{
        didSet{
            setupProfile()
            setupImageContent()
            setupComments()
        }
    }
    
    func setupProfile(){}
    func setupImageContent(){}
    func setupComments(){}
}
