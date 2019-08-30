//
//  FavoriteController.swift
//  NyTimesNews
//
//  Created by Yolankyi SERHII on 8/30/19.
//  Copyright © 2019 Yolankyi Serhii. All rights reserved.
//

import UIKit

class FavoriteController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

extension FavoriteController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as! FavoriteCell
        return cell
    }
}
