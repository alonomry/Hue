//
//  CollectionFeedCell.swift
//  Hue-Demo
//
//  Created by Omry Dabush on 24/12/2016.
//  Copyright © 2016 Omry Dabush. All rights reserved.
//

import UIKit

class CollectionFeedCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var uploadedImage: UIImageView!

    @IBOutlet weak var numOfLikes: UILabel!
    @IBOutlet weak var uploadedImageComments: UILabel!
    @IBOutlet weak var elapsedTimeSinceUpload: UILabel!
    
    @IBOutlet weak var commentButton: UIButton!
    
    @IBAction func test(_ sender: Any) {
        
        //Creating a file into the FileManager Documents directory
        
        let fileManager = FileManager.default
        
            
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        print(documentsDirectory[0])
        
        let filePath = documentsDirectory[0].appendingPathComponent("uid")
        print(filePath)

        
        do {
            try fileManager.createDirectory(at: filePath, withIntermediateDirectories: false, attributes: nil)
            print("Success!")
        } catch let error {
            print(error)
        }

        //EOF
        
    }
    
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
