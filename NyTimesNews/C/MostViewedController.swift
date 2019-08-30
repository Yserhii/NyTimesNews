//
//  MostViewedController.swift
//  NyTimesNews
//
//  Created by Yolankyi SERHII on 8/29/19.
//  Copyright © 2019 Yolankyi Serhii. All rights reserved.
//

import UIKit
import SwiftyJSON
import SafariServices

class MostViewedController: UIViewController {

    private var news: JSON?
    private let category: String = "viewed"
    private let requestManeger = RequestManeger()
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getViewedNews()
    }
}

extension MostViewedController: UITableViewDelegate, UITableViewDataSource, SFSafariViewControllerDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news?["results"].count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ViewedCell", for: indexPath) as! MostViewedCell
        cell.data = news?["results"][indexPath.row]
        self.tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .fade)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! MostViewedCell
        if let url = URL(string: cell.url) {
            let vc = SFSafariViewController(url: url)
            vc.delegate = self
            present(vc, animated: true, completion: nil)
        }
    }
}

extension MostViewedController {
    
    func getViewedNews() {
        requestManeger.getNew(category: self.category, soursForShared: "", completationHandler: { [weak self] response in
            guard let self = self else { return }
            if let response = response {
                self.news = response
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                self.alertError(title: "Error", message: "No connection to the news source server. Try later")
            }
        })
    }
    
    
    func alertError(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}
