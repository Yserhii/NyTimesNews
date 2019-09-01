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
    
    private var page: Int = 0
    private var numNews: Int = 0
    private var news: [JSON?] = []
    private var firstRequestNews: Bool = false
    private var soursesForShared = "facebook"
    private let category: String = "shared"
    private let requestManeger = RequestManeger()
    private let favoriteNewsCore = FavoriteNewsCore()
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func clickScrollTop(_ sender: UIButton) {
        //scrollToTop when click buttom
        self.tableView.scrollToTop(animated: true)
    }
    
    @IBAction func soursesSegmentControl(_ sender: UISegmentedControl) {
        //Change different sources
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
        self.numNews = 0
        self.news.removeAll()
        self.tableView.reloadData()
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
        //Check for duplicate news
        for index in self.favoriteNewsCore.favoriteNews {
            if JSON(index.value(forKeyPath: "news")!)["url"].string == cell.url {
                return true
            }
        }
        return false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Request for first 20 news
        if firstRequestNews == false {
            getSharedNews()
        }
        self.favoriteNewsCore.take()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.prefetchDataSource = self
        configureRefreshControl()
    }
}

extension MostSharedController: UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching, SFSafariViewControllerDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numNews
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SharedCell", for: indexPath) as! MostSharedCell
        if news.count > indexPath.row {
            cell.data = news[indexPath.row]
            self.tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .fade)
        } else {
            cell.dataEmpty()
        }
        return cell
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Select action for open news in Safary
        let cell = tableView.cellForRow(at: indexPath) as! MostSharedCell
        if let url = URL(string: cell.url) {
            let vc = SFSafariViewController(url: url)
            vc.delegate = self
            present(vc, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //Swipe left for add to favorites
        let favoriteNews = UIContextualAction(style: .normal, title: "") { [weak self] action, view, completion in
            guard let self = self else { return }
            let cell = tableView.cellForRow(at: indexPath) as! MostSharedCell
            if self.checkForDuplicateNews(cell: cell) == true {
                self.alertError(title: "", message: "This news has already been added to your favorites.")
            } else {
                self.favoriteNewsCore.save(oneNews: self.news[indexPath.row], image: cell.newsImage?.image)
            }
            completion(true)
        }
        favoriteNews.image = resizedImage(image: #imageLiteral(resourceName: "favorite"), for: CGSize(width: 35.0, height: 35.0))
        favoriteNews.backgroundColor = .green
        return UISwipeActionsConfiguration(actions: [favoriteNews])
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        //Auto-load news using prefetchRowsAt. For one request, get 20 news.
        for indexPath in indexPaths {
            if indexPath.row % 20 == 0 && indexPath.row < self.numNews && indexPath.row != 0 && indexPath.row > self.page {
                self.fetchNews(ofIndex: indexPath.row)
            }
        }
    }
}

extension MostSharedController {
    
    func fetchNews(ofIndex index: Int) {
        //Request for the next page with 20 news
        self.page += 20
        requestManeger.getNew(category: self.category, soursForShared: "", page: self.page, completationHandler: { [weak self] response in
            guard let self = self else { return }
            if let response = response {
                self.news.append(contentsOf: response["results"].array ?? [])
            }
        })
    }
    
    func getSharedNews() {
        //Request for the news
        self.page = 0
        requestManeger.getNew(category: self.category, soursForShared: self.soursesForShared, page: 0, completationHandler: { [weak self] response in
            guard let self = self else { return }
            if let response = response {
                if response["fault"]["detail"]["errorcode"] != "policies.ratelimit.QuotaViolation" {
                    self.news = response["results"].array ?? []
                    self.numNews = response["num_results"].int ?? 0
                    self.firstRequestNews = true
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else {
                    self.alertError(title: "Error", message: "No connection to the news source server. Try later")
                }
            } else {
                self.alertError(title: "Error", message: "No connection to the news source server. Try later")
            }
        })
    }
    
    func resizedImage(image: UIImage, for size: CGSize) -> UIImage? {
         //Change size image
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
