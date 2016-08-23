//
//  Story.swift
//  News Feed
//
//  Created by Ben Wu on 2016-07-10.
//  Copyright © 2016 Ben Wu. All rights reserved.
//

import UIKit

class Story: NSObject, NSCoding {

    // MARK: Properties

    var id: String
    var title: String
    var status: String
    var date: String
    var summary: String
    var timestamp: Int
    var imageUrl: String
    var categories: [String]
    
    struct PropertyKey {
        static let idKey = "id"
        static let titleKey = "title"
        static let statusKey = "status"
        static let dateKey = "date"
        static let summaryKey = "summary"
        static let timestampKey = "timestamp"
        static let imageUrlKey = "imageUrl"
        static let categoryKey = "catergories"
    }
    
    func toString() -> String {
        return "Story: id: \(id), title: \(title), status: \(status), date: \(date), " +
            "summary: \(summary), timestamp: \(timestamp), imageUrl: \(imageUrl), categories: \(categories.count)"
    }
    
    // MARK: Initialization
    
    init(id: String, title: String, status: String, date: String, summary: String, timestamp: Int,
         imageUrl: String, categories: [String]) {
        self.id = id
        self.title = title
        self.status = status
        self.date = date
        self.imageUrl = imageUrl
        self.summary = summary
        self.timestamp = timestamp
        self.categories = categories
        
        super.init()
    }
    
    // MARK: NSCoding
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: PropertyKey.idKey)
        aCoder.encodeObject(title, forKey: PropertyKey.titleKey)
        aCoder.encodeObject(status, forKey: PropertyKey.statusKey)
        aCoder.encodeObject(date, forKey: PropertyKey.dateKey)
        aCoder.encodeObject(summary, forKey: PropertyKey.summaryKey)
        aCoder.encodeInteger(timestamp, forKey: PropertyKey.timestampKey)
        aCoder.encodeObject(imageUrl, forKey: PropertyKey.imageUrlKey)
        aCoder.encodeObject(categories, forKey: PropertyKey.categoryKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeObjectForKey(PropertyKey.idKey) as! String
        let title = aDecoder.decodeObjectForKey(PropertyKey.titleKey) as! String
        let status = aDecoder.decodeObjectForKey(PropertyKey.statusKey) as! String
        let date = aDecoder.decodeObjectForKey(PropertyKey.dateKey) as! String
        let summary = aDecoder.decodeObjectForKey(PropertyKey.summaryKey) as! String
        let timestamp = aDecoder.decodeIntegerForKey(PropertyKey.timestampKey)
        let imageUrl = aDecoder.decodeObjectForKey(PropertyKey.imageUrlKey) as! String
        let categories = aDecoder.decodeObjectForKey(PropertyKey.categoryKey) as! [String]
        
        self.init(id: id, title: title, status: status, date: date, summary: summary, timestamp: timestamp,
                  imageUrl: imageUrl, categories: categories)
    }
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("story")

}