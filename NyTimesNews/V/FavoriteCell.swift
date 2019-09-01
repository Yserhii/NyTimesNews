//
//  FavoriteCell.swift
//  
//
//  Created by Yolankyi SERHII on 8/30/19.
//

import UIKit
import SwiftyJSON

class FavoriteCell: UITableViewCell {
    
    lazy var url: String = ""
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var soursce: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var abstract: UILabel!
    @IBOutlet weak var imageNews: UIImageView!
    
    var data: JSON? {
        didSet {
            if data != nil {
                title.text = data?["title"].string ?? ""
                soursce.text = data?["source"].string ?? ""
                date.text = data?["published_date"].string ?? "0000-00-00"
                abstract.text = data?["abstract"].string ?? ""
                self.url = data?["url"].string ?? ""
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
