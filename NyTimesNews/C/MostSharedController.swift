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
    private var firstRequestNews: Bool = false
    private var soursesForShared = "facebook"
    private let category: String = "shared"
    private let requestManeger = RequestManeger()
    private let favoriteNewsCore = FavoriteNewsCore()
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
        getSharedNews()
    }
    
    @objc func handleRefreshControl() {
        getSharedNews()
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    func configureRefreshControl () {
        //Pull to refresh and request by filters
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    
    func checkForDuplicateNews(cell: MostSharedCell) -> Bool {
        for index in self.favoriteNewsCore.favoriteNews {
            if JSON(index.value(forKeyPath: "news")!)["url"].string == cell.url {
                return true
            }
        }
        return false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if firstRequestNews == false {
            getSharedNews()
        }
        self.favoriteNewsCore.take()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRefreshControl()
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let favoriteNews = UIContextualAction(style: .normal, title: "") { [weak self] action, view, completion in
            guard let self = self else { return }
            let cell = tableView.cellForRow(at: indexPath) as! MostSharedCell
            if self.checkForDuplicateNews(cell: cell) == true {
                self.alertError(title: "", message: "This news has already been added to your favorites.")
            } else {
                self.favoriteNewsCore.save(oneNews: self.news?["results"][indexPath.row])
            }
            completion(true)
        }
        favoriteNews.image = resizedImage(image: #imageLiteral(resourceName: "favorite"), for: CGSize(width: 35.0, height: 35.0))
        favoriteNews.backgroundColor = .green
        return UISwipeActionsConfiguration(actions: [favoriteNews])
    }
}

extension MostSharedController {
    
    func getSharedNews() {
        requestManeger.getNew(category: self.category, soursForShared: self.soursesForShared, completationHandler: { [weak self] response in
            guard let self = self else { return }
            if let response = response {
                self.news = response
                self.firstRequestNews = true
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                self.alertError(title: "Error", message: "No connection to the news source server. Try later")
            }
        })
    }
    
    func resizedImage(image: UIImage, for size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func alertError(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}
