//
//  MostViewedCell.swift
//  NyTimesNews
//
//  Created by Yolankyi SERHII on 8/29/19.
//  Copyright © 2019 Yolankyi Serhii. All rights reserved.
//

import UIKit
import SwiftyJSON

class MostViewedCell: UITableViewCell {

    lazy var url: String = ""
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var soursce: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var imageNews: UIImageView!
    
    var data: JSON? {
        didSet {
            if data != nil {
                self.imageNews.isHidden = true
                title.text = data?["title"].string ?? ""
                soursce.text = data?["source"].string ?? ""
                date.text = data?["published_date"].string ?? "0000-00-00"
                self.url = data?["url"].string ?? ""
                if let image = URL(string: data?["media"][0]["media-metadata"][1]["url"].string ?? "") {
                    self.imageNews.isHidden = false
                    let queue = DispatchQueue.global(qos: .utility)
                    queue.async {
                        if let isImage = try? Data(contentsOf: image) {
                            DispatchQueue.main.async {
                                self.imageNews.image = UIImage(data: isImage)
                                self.imageNews.contentMode = .scaleAspectFit
                            }
                        }
                    }
                }
            }
        }
    }
    
    func dataEmpty() {
        self.url = ""
        self.title.text = "The limit of 6 requests per minute has been reached. Try again in  one minutes."
        self.soursce.text = ""
        self.date.text = ""
        self.imageNews.image = .none
        self.imageNews.isHidden = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
