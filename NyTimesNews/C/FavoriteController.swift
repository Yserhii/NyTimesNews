//
//  FavoriteController.swift
//  NyTimesNews
//
//  Created by Yolankyi SERHII on 8/30/19.
//  Copyright © 2019 Yolankyi Serhii. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON
import SafariServices

class FavoriteController: UIViewController {
    
    private var flagForSafari = false
    private var news: [JSON?] = []
    @IBOutlet weak var tableView: UITableView!
    private let favoriteNewsCore = FavoriteNewsCore()
    
    @IBAction func clickScrollTop(_ sender: UIButton) {
        //scrollToTop when click buttom
        self.tableView.scrollToTop(animated: true)
    }
    
    func addNewsFromCoreData() {
        //Add news in arr from CoreData
        for oneNews in self.favoriteNewsCore.favoriteNews {
            if let oneNews = oneNews.value(forKeyPath: "news") {
                news.append(JSON(oneNews))
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if self.flagForSafari == false {
            self.news.removeAll()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.flagForSafari == false {
            self.favoriteNewsCore.take()
            self.addNewsFromCoreData()
            self.tableView.reloadData()
        } else {
            self.flagForSafari = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension FavoriteController: UITableViewDelegate, UITableViewDataSource, SFSafariViewControllerDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as! FavoriteCell
        cell.data = news[indexPath.row]
        if let dataImage = self.favoriteNewsCore.favoriteNews[indexPath.row].value(forKeyPath: "image") {
            cell.imageNews.image = UIImage(data: dataImage as! Data)
        } else {
            cell.imageNews.image = .none
            cell.imageNews.isHidden = true
        }
        return cell
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Select action for open news in Safary
        let cell = tableView.cellForRow(at: indexPath) as! FavoriteCell
        if let url = URL(string: cell.url) {
            let vc = SFSafariViewController(url: url)
            vc.delegate = self
            self.flagForSafari = true
            present(vc, animated: true, completion: nil)
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //Swipe left for delete form favorite
        let delete = UIContextualAction(style: .destructive, title: "") { [weak self] action, view, completion in
            guard let self = self else { return }
            self.favoriteNewsCore.delete(indexPath: indexPath.row)
            self.news.remove(at: indexPath.row)
            completion(false)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        delete.image = resizedImage(image: #imageLiteral(resourceName: "delete"), for: CGSize(width: 35.0, height: 35.0))
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

extension FavoriteController {
    
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
