//
//  CommentsController.swift
//  Hue
//
//  Created by alon tal on 24/12/2016.
//  Copyright © 2016 Omry Dabush. All rights reserved.
//

import UIKit

class CommentsController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var CommentsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableview()
    }
    
    func setupTableview(){
        CommentsTableView.delegate = self
        CommentsTableView.dataSource = self
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let nib = UINib(nibName: "CommentsCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "CommentsCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsCell", for: indexPath)
        
        return cell
    }

}
