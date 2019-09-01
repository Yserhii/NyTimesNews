//
//  FavoriteNewsCore.swift
//  NyTimesNews
//
//  Created by Yolankyi SERHII on 8/31/19.
//  Copyright © 2019 Yolankyi Serhii. All rights reserved.
//

import UIKit
import CoreData
import Foundation
import SwiftyJSON

class FavoriteNewsCore: UIViewController {

    var favoriteNews: [NSManagedObject] = []
    
    func save(oneNews: JSON?, image: UIImage?) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "FavoriteNews", in: managedContext)!
        let news = NSManagedObject(entity: entity, insertInto: managedContext)
        
        do {
            let data = try oneNews?.rawData()
            let dataImage = image?.pngData()
            news.setValue(dataImage, forKey: "image")
            news.setValue(data, forKeyPath: "news")
        } catch let error as NSError {
            print("NSJSONSerialization Error: \(error)")
            return
        }
        
        do {
            try managedContext.save()
            favoriteNews.append(news)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func delete(indexPath: Int) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        do {
            managedContext.delete(favoriteNews[indexPath])
            favoriteNews.remove(at: indexPath)
            try managedContext.save()
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }
    
    
    func take() {
    
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FavoriteNews")
        do {
            favoriteNews = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}
