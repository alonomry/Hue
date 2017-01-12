//
//  ExploreController.swift
//  Hue
//
//  Created by Omry Dabush on 11/01/2017.
//  Copyright © 2017 Omry Dabush. All rights reserved.
//

import UIKit

class ExploreController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    let feedXib = UINib(nibName: "tableFeedCell", bundle: nil)
    
    @IBOutlet weak var mainTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurAssets()
    }
    
    func configurAssets(){
        mainTableView.delegate = self
        mainTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 62
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = tableView.frame.width * (5 / 4)
        return height + 150 - 63
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.register(feedXib, forCellReuseIdentifier: "tableFeedCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableFeedCell") as! TableFeedCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        tableView.register(feedXib, forHeaderFooterViewReuseIdentifier: "tableFeedHeader")
        let header = Bundle.main.loadNibNamed("tableFeedHeader", owner: self, options: nil)?.first as! TableFeedHeader
        header.profileImage.layer.cornerRadius = 22
        header.profileImage.layer.masksToBounds = true
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
