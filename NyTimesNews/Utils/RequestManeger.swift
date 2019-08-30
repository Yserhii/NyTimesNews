//
//  RequestManeger.swift
//  NyTimesNews
//
//  Created by Yolankyi SERHII on 8/29/19.
//  Copyright © 2019 Yolankyi Serhii. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RequestManeger {
    
    private let key: String = "Feq2m5T5TceFo3z66BRfHFIoxFj1rBNq"
    private let site: String = "https://api.nytimes.com/svc/mostpopular/v2/"
    private let day: String = "/30/"
    
    func getNew(category: String, soursForShared: String, completationHandler: @escaping(JSON?) -> Void) {
        
        let reqUrlCurrent: String = "\(self.site)\(category)\(self.day)\(soursForShared).json?api-key=\(self.key)"
        print(reqUrlCurrent)
        Alamofire.request(reqUrlCurrent).responseJSON { response in
            if response.result.isSuccess {
                completationHandler(JSON(response.data!))
            } else {
                print(response.error!.localizedDescription)
                completationHandler(nil)
            }
        }.task?.resume()
    }
}
