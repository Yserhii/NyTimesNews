//
//  MostSharedController.swift
//  NyTimesNews
//
//  Created by Yolankyi SERHII on 8/29/19.
//  Copyright © 2019 Yolankyi Serhii. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SafariServices

class MostSharedController: UIViewController {
    
    private var news: JSON?
    private var soursesForShared = "facebook"
    private let category: String = "shared"
    private let requestManeger = RequestManeger()
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func soursesSegmentControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
                self.soursesForShared = "facebook"
            case 1:
                self.soursesForShared = "email"
            case 2:
                self.soursesForShared = "twitter"
            default:
                break;
        }
        getViewedNews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getViewedNews()
    }
}

extension MostSharedController: UITableViewDelegate, UITableViewDataSource, SFSafariViewControllerDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news?["results"].count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SharedCell", for: indexPath) as! MostSharedCell
        cell.data = news?["results"][indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! MostSharedCell
        if let url = URL(string: cell.url) {
            let vc = SFSafariViewController(url: url)
            vc.delegate = self
            present(vc, animated: true, completion: nil)
        }
    }
}

extension MostSharedController {
    
    func getViewedNews() {
        requestManeger.getNew(category: self.category, soursForShared: self.soursesForShared, completationHandler: { [weak self] response in
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
